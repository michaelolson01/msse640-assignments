(defpackage #:user-api
            (:use #:cl #:hunchentoot #:sqlite)
            (:export #:start-server #:stop-server #:init-db))

(in-package #:user-api)

(defvar *server* nil
  "The Hunchentoot server instance.")

(defvar *db-path* "users.db"
  "Path to the SQLite database file.")

;;; Database functions

(defun init-db ()
  "Initialize the SQLite database with the users table."
  (sqlite:with-open-database (db *db-path*)
    (sqlite:execute-non-query db
      "CREATE TABLE IF NOT EXISTS users (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         username TEXT UNIQUE NOT NULL,
         created_at DATETIME DEFAULT CURRENT_TIMESTAMP
       )")))

(defun add-user (username)
  "Add a new user to the database. Returns T on success, NIL if user exists."
  (handler-case
      (sqlite:with-open-database (db *db-path*)
        (sqlite:execute-non-query db
          "INSERT INTO users (username) VALUES (?)"
          username)
        t)
    (sqlite:sqlite-error (e)
      (if (search "UNIQUE constraint failed" (format nil "~A" e))
          nil
          (error e)))))

(defun get-all-users ()
  "Get all users from the database. Returns a list of plists."
  (sqlite:with-open-database (db *db-path*)
    (let ((rows (sqlite:execute-to-list db
                  "SELECT id, username, created_at FROM users ORDER BY created_at DESC")))
      (mapcar (lambda (row)
                (list :id (first row)
                      :username (second row)
                      :created_at (third row)))
              rows))))

(defun get-user (username)
  "Get a specific user by username. Returns a plist or NIL."
  (sqlite:with-open-database (db *db-path*)
    (let ((rows (sqlite:execute-to-list db
                  "SELECT id, username, created_at FROM users WHERE username = ?"
                  username)))
      (when rows
        (let ((row (first rows)))
          (list :id (first row)
                :username (second row)
                :created_at (third row)))))))

(defun delete-user (username)
  "Delete a user by username. Returns T if deleted, NIL if not found."
  (let ((existed (user-exists-p username)))
    (when existed
      (sqlite:with-open-database (db *db-path*)
        (sqlite:execute-non-query db
          "DELETE FROM users WHERE username = ?"
          username)))
    existed))

(defun user-exists-p (username)
  "Check if a user exists in the database."
  (not (null (get-user username))))

;;; JSON conversion functions

(defun plist-to-json (plist)
  "Convert a plist to JSON string."
  (with-output-to-string (s)
    (write-char #\{ s)
    (loop for (key value) on plist by #'cddr
          for first = t then nil
          unless first do (write-string ", " s)
          do (format s "\"~A\": " (string-downcase (symbol-name key)))
          do (if (stringp value)
                 (format s "\"~A\"" value)
                 (format s "~A" value)))
    (write-char #\} s)))

(defun list-to-json-array (list)
  "Convert a list of plists to JSON array string."
  (with-output-to-string (s)
    (write-char #\[ s)
    (loop for item in list
          for first = t then nil
          unless first do (write-string ", " s)
          do (write-string (plist-to-json item) s))
    (write-char #\] s)))

;;; HTTP handlers

(defun set-json-headers ()
  "Set common JSON response headers including CORS."
  (setf (content-type*) "application/json")
  (setf (header-out "Access-Control-Allow-Origin") "*")
  (setf (header-out "Access-Control-Allow-Methods") "GET, POST, DELETE, OPTIONS")
  (setf (header-out "Access-Control-Allow-Headers") "Content-Type"))

(defun parse-json-body ()
  "Parse JSON from request body."
  (handler-case
      (let* ((body (raw-post-data :force-text t))
             (json-str (if (stringp body) body (octets-to-string body :external-format :utf-8))))
        (when (and json-str (> (length json-str) 0))
          (cl-json:decode-json-from-string json-str)))
    (error (e)
      (format t "Error parsing JSON: ~A~%" e)
      nil)))

(define-easy-handler (users-handler :uri "/users") ()
  (set-json-headers)
  (cond
    ((eq (request-method*) :OPTIONS)
     ;; Handle CORS preflight
     "")
    ((eq (request-method*) :GET)
     ;; List all users
     (let ((users (get-all-users)))
       (list-to-json-array users)))
    ((eq (request-method*) :POST)
     ;; Create a new user
     (let* ((json-data (parse-json-body))
            (username (cdr (assoc :username json-data))))
       (cond
         ((null username)
          (setf (return-code*) +http-bad-request+)
          "{\"error\": \"Username is required\"}")
         ((string= username "")
          (setf (return-code*) +http-bad-request+)
          "{\"error\": \"Username cannot be empty\"}")
         ((add-user username)
          (setf (return-code*) +http-created+)
          (let ((user (get-user username)))
            (plist-to-json user)))
         (t
          (setf (return-code*) +http-conflict+)
          "{\"error\": \"Username already exists\"}"))))
    (t
     (setf (return-code*) +http-method-not-allowed+)
     "{\"error\": \"Method not allowed\"}")))

(defun user-detail-handler (username)
  "Handler for /users/:username endpoints"
  (set-json-headers)
  (cond
    ((eq (request-method*) :GET)
     (let ((user (get-user username)))
       (if user
           (plist-to-json user)
           (progn
             (setf (return-code*) +http-not-found+)
             "{\"error\": \"User not found\"}"))))
    ((eq (request-method*) :DELETE)
     (if (delete-user username)
         "{\"message\": \"User deleted successfully\"}"
         (progn
           (setf (return-code*) +http-not-found+)
           "{\"error\": \"User not found\"}")))
    (t
     (setf (return-code*) +http-method-not-allowed+)
     "{\"error\": \"Method not allowed\"}")))

(defun user-detail-dispatcher (request)
  "Custom dispatcher for /users/:username paths"
  (let ((path (script-name request)))
    (when (and (>= (length path) 7)
               (string= path "/users/" :end1 7))
      (let ((username (subseq path 7)))
        (when (and username (> (length username) 0))
          (lambda ()
            (user-detail-handler username)))))))

(push 'user-detail-dispatcher *dispatch-table*)

(define-easy-handler (index-handler :uri "/") ()
  (setf (content-type*) "text/html")
  "<html>
    <head><title>User Management API</title></head>
    <body>
      <h1>User Management API</h1>
      <h2>Endpoints:</h2>
      <ul>
        <li><strong>GET /users</strong> - List all users</li>
        <li><strong>GET /users/:username</strong> - Get a specific user</li>
        <li><strong>POST /users</strong> - Create a new user (JSON body: {\"username\": \"...\"})</li>
        <li><strong>DELETE /users/:username</strong> - Delete a user</li>
      </ul>
      <h2>Examples:</h2>
      <pre>
# List all users
curl http://localhost:8081/users

# Get a specific user
curl http://localhost:8081/users/john

# Create a user
curl -X POST http://localhost:8081/users \\
  -H \"Content-Type: application/json\" \\
  -d '{\"username\": \"john\"}'

# Delete a user
curl -X DELETE http://localhost:8081/users/john
      </pre>
    </body>
  </html>")

(defun start-server (&key (port 8081))
  "Start the Hunchentoot server on the specified port."
  (when *server*
    (format t "Server already running. Stopping old server...~%")
    (stop-server))
  
  ;; Initialize database
  (init-db)
  (format t "Database initialized at ~A~%" *db-path*)
  
  (setf *server* (make-instance 'easy-acceptor :port port))
  (start *server*)
  (format t "User API server started on port ~A~%" port)
  (format t "Visit http://localhost:~A/ for API documentation~%" port)
  *server*)

(defun stop-server ()
  "Stop the Hunchentoot server."
  (when *server*
    (stop *server*)
    (setf *server* nil)
    (format t "Server stopped.~%")))
