(defpackage #:testing-game
  (:use #:cl #:hunchentoot)
  (:export #:start-server #:stop-server))

(in-package #:testing-game)

(defvar *server* nil
  "The Hunchentoot server instance.")

;;; Game scenarios database - WITH INTENTIONAL ERRORS FOR PLAYERS TO FIND
(defvar *scenarios* 
  '((:id 1
     :title "Age Validation (0-120)"
     :description "A system accepts ages from 0 to 120 (inclusive). Identify the equivalence classes and boundary values for different age groups. WARNING: This specification contains errors!"
     :min 0
     :max 120
     :valid-classes ("0-12 (child)" "13-18 (teen)" "18-24 (young adult)" "25-64 (adult)" "65-120 (senior)")
     :invalid-classes ("Below minimum (<0)" "Above maximum (>120)")
     :boundary-values (-1 0 12 13 17 18 24 25 64 65 120 121)
     :errors ((:id 1 :description "Teen range should be 13-17, not 13-18" :location "valid-classes")
              (:id 2 :description "Young adult range overlaps with teen (both include 18)" :location "valid-classes")
              (:id 3 :description "Boundary value 17 is missing" :location "boundary-values"))
     :test-cases ((-1 . :invalid) (0 . :valid) (6 . :valid) (12 . :valid) 
                  (13 . :valid) (17 . :valid) (18 . :valid) (24 . :valid)
                  (25 . :valid) (50 . :valid) (64 . :valid) (65 . :valid)
                  (100 . :valid) (120 . :valid) (121 . :invalid)))
    
    (:id 2
     :title "Temperature Range (0-100°F)"
     :description "A temperature sensor measures from 0°F to 100°F. Identify the equivalence classes for different temperature zones. WARNING: This specification contains errors!"
     :min 0
     :max 100
     :valid-classes ("0-33°F (freezing)" "33-59°F (cold)" "60-79°F (mild)" "80-100°F (hot)")
     :invalid-classes ("Below range (<0)" "Above range (>100)")
     :boundary-values (-1 0 32 33 59 60 79 80 100 101)
     :errors ((:id 1 :description "Freezing should be 0-32°F, not 0-33°F" :location "valid-classes")
              (:id 2 :description "Cold range overlaps with freezing (both include 33)" :location "valid-classes"))
     :test-cases ((-1 . :invalid) (0 . :valid) (20 . :valid) (32 . :valid)
                  (33 . :valid) (50 . :valid) (59 . :valid) (60 . :valid)
                  (70 . :valid) (79 . :valid) (80 . :valid) (95 . :valid)
                  (100 . :valid) (101 . :invalid)))
    
    (:id 3
     :title "Exam Score (0-100)"
     :description "Exam scores range from 0 to 100 points. Identify valid and invalid ranges with letter grades. WARNING: This specification contains errors!"
     :min 0
     :max 100
     :valid-classes ("90-100 (A)" "79-89 (B)" "70-79 (C)" "60-69 (D)" "0-59 (F)")
     :invalid-classes ("Negative scores (<0)" "Scores above 100 (>100)")
     :boundary-values (-1 0 59 60 69 70 79 80 89 90 100 101)
     :errors ((:id 1 :description "B grade should be 80-89, not 79-89" :location "valid-classes")
              (:id 2 :description "C grade overlaps with B (both include 79)" :location "valid-classes")
              (:id 3 :description "Missing boundary value 80 in boundary list" :location "boundary-values"))
     :test-cases ((-1 . :invalid) (0 . :valid) (30 . :valid) (59 . :valid)
                  (60 . :valid) (69 . :valid) (70 . :valid) (79 . :valid)
                  (80 . :valid) (89 . :valid) (90 . :valid) (100 . :valid)
                  (101 . :invalid)))))

(defun get-scenario (id)
  "Get a scenario by ID."
  (find id *scenarios* :key (lambda (s) (getf s :id))))

(defun get-all-scenarios ()
  "Get all scenarios."
  *scenarios*)

(defun get-equivalence-class (scenario value)
  "Determine which equivalence class a value belongs to."
  (let ((min (getf scenario :min))
        (max (getf scenario :max))
        (id (getf scenario :id)))
    (cond
      ;; Below range
      ((< value min)
       (if (= id 3) 
           "Negative scores (<0)"
           (if (= id 1) "Below minimum (<0)" "Below range (<0)")))
      ;; Above range  
      ((> value max)
       (if (= id 3)
           "Scores above 100 (>100)"
           (if (= id 1) "Above maximum (>120)" "Above range (>100)")))
      ;; Within valid range - determine specific class
      (t
       (cond
         ;; Age validation (ID 1)
         ((= id 1)
          (cond
            ((<= 0 value 12) "0-12 (child)")
            ((<= 13 value 17) "13-17 (teen)")
            ((<= 18 value 24) "18-24 (young adult)")
            ((<= 25 value 64) "25-64 (adult)")
            ((<= 65 value 120) "65-120 (senior)")))
         ;; Temperature (ID 2)
         ((= id 2)
          (cond
            ((<= 0 value 32) "0-32°F (freezing)")
            ((<= 33 value 59) "33-59°F (cold)")
            ((<= 60 value 79) "60-79°F (mild)")
            ((<= 80 value 100) "80-100°F (hot)")))
         ;; Exam score (ID 3)
         ((= id 3)
          (cond
            ((<= 90 value 100) "90-100 (A)")
            ((<= 80 value 89) "80-89 (B)")
            ((<= 70 value 79) "70-79 (C)")
            ((<= 60 value 69) "60-69 (D)")
            ((<= 0 value 59) "0-59 (F)"))))))))

(defun is-boundary-value (scenario value)
  "Check if a value is a key boundary value for the scenario."
  (member value (getf scenario :boundary-values)))

(defun get-errors (scenario)
  "Get all errors for a scenario."
  (getf scenario :errors))

(defun get-error-by-id (scenario error-id)
  "Get a specific error by ID."
  (find error-id (get-errors scenario) :key (lambda (e) (getf e :id))))

;;; JSON conversion
(defun plist-to-json (plist)
  "Convert a plist to JSON string."
  (cl-json:encode-json-plist-to-string plist))

(defun set-json-headers ()
  "Set JSON response headers with CORS."
  (setf (content-type*) "application/json")
  (setf (header-out "Access-Control-Allow-Origin") "*")
  (setf (header-out "Access-Control-Allow-Methods") "GET, POST, OPTIONS")
  (setf (header-out "Access-Control-Allow-Headers") "Content-Type"))

;;; HTTP Handlers

(define-easy-handler (index :uri "/") ()
  (setf (content-type*) "text/html")
  (with-open-file (stream (merge-pathnames "game.html" 
                                          (asdf:system-source-directory :testing-game))
                          :direction :input
                          :if-does-not-exist nil)
    (if stream
        (let ((content (make-string (file-length stream))))
          (read-sequence content stream)
          content)
        "<html><body><h1>Error: game.html not found</h1></body></html>")))

(define-easy-handler (scenarios-list :uri "/api/scenarios") ()
  (set-json-headers)
  (let ((scenarios (mapcar (lambda (s)
                            (list (cons :id (getf s :id))
                                  (cons :title (getf s :title))
                                  (cons :description (getf s :description))))
                          (get-all-scenarios))))
    (cl-json:encode-json-to-string scenarios)))

(define-easy-handler (scenario-detail :uri "/api/scenario") (id)
  (set-json-headers)
  (let* ((scenario-id (parse-integer id :junk-allowed t))
         (scenario (get-scenario scenario-id)))
    (if scenario
        (cl-json:encode-json-to-string
         (list (cons :id (getf scenario :id))
               (cons :title (getf scenario :title))
               (cons :description (getf scenario :description))
               (cons :min (getf scenario :min))
               (cons :max (getf scenario :max))
               (cons :valid-classes (getf scenario :valid-classes))
               (cons :invalid-classes (getf scenario :invalid-classes))
               (cons :total-errors (length (get-errors scenario)))))
        (progn
          (setf (return-code*) +http-not-found+)
          "{\"error\": \"Scenario not found\"}"))))

(define-easy-handler (check-test :uri "/api/check") (scenario-id value)
  (set-json-headers)
  (let* ((sid (parse-integer scenario-id :junk-allowed t))
         (val (parse-integer value :junk-allowed t))
         (scenario (get-scenario sid))
         (class (get-equivalence-class scenario val))
         (is-boundary (is-boundary-value scenario val))
         (min (getf scenario :min))
         (max (getf scenario :max))
         (is-valid (and (>= val min) (<= val max))))
    (cl-json:encode-json-to-string
     (list (cons :value val)
           (cons :class class)
           (cons :is-valid is-valid)
           (cons :is-boundary is-boundary)
           (cons :message (format nil "Value ~A belongs to: ~A~A" 
                                 val 
                                 class
                                 (if is-boundary " [BOUNDARY VALUE]" "")))))))

(define-easy-handler (get-solution :uri "/api/solution") (id)
  (set-json-headers)
  (let* ((scenario-id (parse-integer id :junk-allowed t))
         (scenario (get-scenario scenario-id)))
    (if scenario
        (cl-json:encode-json-to-string
         (list (cons :boundary-values (getf scenario :boundary-values))
               (cons :test-cases (mapcar (lambda (tc)
                                          (list (car tc) (cdr tc)))
                                        (getf scenario :test-cases)))
               (cons :errors (mapcar (lambda (e)
                                      (list (cons :id (getf e :id))
                                            (cons :description (getf e :description))
                                            (cons :location (getf e :location))))
                                    (get-errors scenario)))))
        (progn
          (setf (return-code*) +http-not-found+)
          "{\"error\": \"Scenario not found\"}"))))

(defun start-server (&key (port 8082))
  "Start the Hunchentoot server."
  (when *server*
    (format t "Server already running. Stopping old server...~%")
    (stop-server))
  
  (setf *server* (make-instance 'easy-acceptor :port port))
  (start *server*)
  (format t "Testing Game server started on port ~A~%" port)
  (format t "Visit http://localhost:~A/ to play the game~%" port)
  *server*)

(define-easy-handler (report-error :uri "/api/report-error") (scenario-id error-description)
  (set-json-headers)
  (let* ((sid (parse-integer scenario-id :junk-allowed t))
         (scenario (get-scenario sid))
         (errors (get-errors scenario)))
    (if scenario
        ;; Check if the reported error matches any actual errors (fuzzy match on keywords)
        (let ((matches (remove-if-not 
                        (lambda (e)
                          (let ((desc (string-downcase (getf e :description)))
                                (report (string-downcase error-description)))
                            (or (search report desc)
                                (search desc report)
                                (and (search "overlap" report) (search "overlap" desc))
                                (and (search "missing" report) (search "missing" desc))
                                (and (search "boundary" report) (search "boundary" desc)))))
                        errors)))
          (if matches
              (cl-json:encode-json-to-string
               (list (cons :found t)
                     (cons :error-id (getf (first matches) :id))
                     (cons :description (getf (first matches) :description))
                     (cons :message "Great job! You found an error!")))
              (cl-json:encode-json-to-string
               (list (cons :found nil)
                     (cons :message "Keep looking! That's not quite right.")))))
        (progn
          (setf (return-code*) +http-not-found+)
          "{\"error\": \"Scenario not found\"}"))))

(defun stop-server ()
  "Stop the Hunchentoot server."
  (when *server*
    (stop *server*)
    (setf *server* nil)
    (format t "Server stopped.~%")))
