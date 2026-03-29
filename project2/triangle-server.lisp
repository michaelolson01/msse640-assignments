(defpackage #:triangle-api
  (:use #:cl #:hunchentoot)
  (:export #:start-server #:stop-server))

(in-package #:triangle-api)

(defvar *server* nil
  "The Hunchentoot server instance.")

(defun classify-triangle (a b c)
  "Classify a triangle based on the lengths of its sides.

   Args:
     a, b, c: The lengths of the three sides

   Returns:
     A string describing the triangle type"
  (cond
   ;; Check if inputs are numbers
   ((not (numberp a)) "Invalid: All sides must be numbers")
   ((not (numberp b)) "Invalid: All sides must be numbers")
   ((not (numberp c)) "Invalid: All sides must be numbers")
   ;; Check if inputs are complex numbers
   ((complexp a) "Invalid: Complex numbers are not allowed")
   ((complexp b) "Invalid: Complex numbers are not allowed")
   ((complexp c) "Invalid: Complex numbers are not allowed")
   ;; Check if all sides are positive
   ((<= a 0) "Invalid: All sides must be positive numbers")
   ((<= b 0) "Invalid: All sides must be positive numbers")
   ((<= c 0) "Invalid: All sides must be positive numbers")
   ;; Check triangle inequality
   ((<= (+ a b) c) "Not a triangle: Does not satisfy triangle inequality")
   ((<= (+ a c) b) "Not a triangle: Does not satisfy triangle inequality")
   ((<= (+ b c) a) "Not a triangle: Does not satisfy triangle inequality")
   ;; Classify the triangle type
   ((and (= a b) (= b c)) "Equilateral triangle")
   ((or (= a b) (= b c) (= a c)) "Isosceles triangle")
   (t "Scalene triangle")))

;; (defun parse-number-parameter (param-string)
;;   "Parse a parameter string to a number. Returns nil if parsing fails."
;;   (handler-case
;;       (let ((num (parse-integer param-string)))
;;         (if (> num 0) num nil))
;;     (error () nil)))

(defun parse-number-parameter (param-string)
  "Parse a parameter string to a number. Returns nil if parsing fails."
  (handler-case
      (let* ((trimmed (string-trim '(#\Space #\Tab #\Newline) param-string))
             (num (read-from-string trimmed nil nil)))
        (if (and (numberp num) (> num 0) (not (complexp num))) 
            num 
            nil))
    (error () nil)))

(define-easy-handler (classify-handler :uri "/classify") (a b c)
  (setf (content-type*) "application/json")
  ;; Add CORS headers to allow cross-origin requests
  (setf (header-out "Access-Control-Allow-Origin") "*")
  (setf (header-out "Access-Control-Allow-Methods") "GET, POST, OPTIONS")
  (setf (header-out "Access-Control-Allow-Headers") "Content-Type")

  (let ((side-a (and a (parse-number-parameter a)))
        (side-b (and b (parse-number-parameter b)))
        (side-c (and c (parse-number-parameter c))))

    (if (and side-a side-b side-c)
        (let ((result (classify-triangle side-a side-b side-c)))
          (format nil "{\"a\": ~A, \"b\": ~A, \"c\": ~A, \"type\": \"~A\"}"
                  side-a side-b side-c result))
        (progn
          (setf (return-code*) +http-bad-request+)
          "{\"error\": \"Invalid parameters. Please provide positive integers for a, b, and c.\"}"))))

(define-easy-handler (index-handler :uri "/") ()
  (setf (content-type*) "text/html")
  "<html>
    <head><title>Triangle Classifier API</title></head>
    <body>
      <h1>Triangle Classifier API</h1>
      <p>Use the /classify endpoint with query parameters a, b, and c to classify a triangle.</p>
      <p>Example: <a href=\"/classify?a=3&b=4&c=5\">/classify?a=3&b=4&c=5</a></p>
      <h2>Test the API:</h2>
      <form action=\"/classify\" method=\"get\">
        Side A: <input type=\"number\" name=\"a\" value=\"3\" required><br><br>
        Side B: <input type=\"number\" name=\"b\" value=\"4\" required><br><br>
        Side C: <input type=\"number\" name=\"c\" value=\"5\" required><br><br>
        <input type=\"submit\" value=\"Classify Triangle\">
      </form>
    </body>
  </html>")

(defun start-server (&key (port 8080))
  "Start the Hunchentoot server on the specified port."
  (when *server*
    (format t "Server already running. Stopping old server...~%")
    (stop-server))
  (setf *server* (make-instance 'easy-acceptor :port port))
  (start *server*)
  (format t "Triangle API server started on port ~A~%" port)
  (format t "Visit http://localhost:~A/ to use the API~%" port)
  *server*)

(defun stop-server ()
  "Stop the Hunchentoot server."
  (when *server*
    (stop *server*)
    (setf *server* nil)
    (format t "Server stopped.~%")))
