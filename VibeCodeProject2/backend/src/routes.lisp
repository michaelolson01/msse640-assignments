(defpackage :testcraft.routes
  (:use :cl :hunchentoot)
  (:import-from :testcraft.auth
                :register-user
                :authenticate-user
                :get-user-by-id)
  (:import-from :testcraft.models.level
                :get-all-levels
                :get-level-by-id)
  (:import-from :testcraft.models.score
                :save-score
                :get-user-scores
                :get-level-leaderboard)
  (:import-from :testcraft.models.user
                :get-user-progress
                :update-user-progress)
  (:import-from :testcraft.validators.decision-table
                :validate-decision-table)
  (:import-from :testcraft.validators.pairwise
                :validate-pairwise)
  (:import-from :testcraft.utils
                :json-response
                :error-response
                :success-response)
  (:export :setup-routes))

(in-package :testcraft.routes)

;; Enable CORS for development
(defun add-cors-headers ()
  (setf (header-out :access-control-allow-origin) "*")
  (setf (header-out :access-control-allow-methods) "GET, POST, OPTIONS")
  (setf (header-out :access-control-allow-headers) "Content-Type"))

;; Handle CORS preflight requests
(define-easy-handler (options-handler :uri (lambda (request)
                                              (and (eq (request-method request) :OPTIONS)
                                                   (starts-with-subseq "/api/" (script-name request)))))
    ()
  (add-cors-headers)
  (setf (return-code*) 200)
  "")

;; Registration endpoint
(define-easy-handler (register :uri "/api/register") (username password email)
  (add-cors-headers)
  (if (and username password)
      (let ((user (register-user username password email)))
        (if user
            (success-response user)
            (error-response "Username already exists")))
      (error-response "Username and password required")))

;; Login endpoint
(define-easy-handler (login :uri "/api/login") (username password)
  (add-cors-headers)
  (if (and username password)
      (let ((user (authenticate-user username password)))
        (if user
            (success-response user)
            (error-response "Invalid credentials")))
      (error-response "Username and password required")))

;; Get all levels
(define-easy-handler (get-levels :uri "/api/levels") ()
  (add-cors-headers)
  (success-response (get-all-levels)))

;; Get specific level
(define-easy-handler (get-level :uri "/api/level") (id)
  (add-cors-headers)
  (if id
      (let ((level (get-level-by-id (parse-integer id))))
        (if level
            (success-response level)
            (error-response "Level not found")))
      (error-response "Level ID required")))

;; Submit solution
(define-easy-handler (submit-solution :uri "/api/submit") ()
  (add-cors-headers)
  ;; Handle OPTIONS preflight
  (when (eq (request-method*) :OPTIONS)
    (setf (return-code*) 200)
    (return-from submit-solution ""))
  (handler-case
      (let* ((post-data (raw-post-data :force-text t))
             (json-data (cl-json:decode-json-from-string post-data))
             (user-id (cdr (assoc :user-id json-data)))
             (level-id (cdr (assoc :level-id json-data)))
             (solution (cdr (assoc :solution json-data))))
        (format t "Submit data - user-id: ~a, level-id: ~a, solution: ~a~%" user-id level-id (if solution "present" "nil"))
        (if (and user-id level-id (not (null solution)))
            (let* ((level (get-level-by-id level-id)))
              (if (null level)
                  (error-response "Level not found or invalid")
                  (let* ((level-type (cdr (assoc :level-type level)))
                         (level-solution (cdr (assoc :solution level)))
                         (level-config (cdr (assoc :config level))))
                    (format t "Level type: ~a (stringp: ~a)~%" level-type (stringp level-type))
                    (if (or (null level-type) (not (stringp level-type)))
                        (error-response "Level not found or invalid")
                        (let* ((result (if (string= level-type "decision_table")
                                          (validate-decision-table solution level-solution)
                                          (validate-pairwise solution level-solution level-config)))
                               (total-score (cdr (assoc :total result)))
                               (completeness (cdr (assoc :completeness result)))
                               (efficiency (cdr (assoc :efficiency result)))
                               (accuracy (cdr (assoc :accuracy result))))
                          (format t "Validation result - score: ~a, completeness: ~a~%" total-score completeness)
                          ;; Save score
                          (save-score user-id level-id total-score completeness efficiency 0 accuracy)
                          ;; Update progress with current timestamp
                          (update-user-progress user-id level-id total-score completeness efficiency accuracy)
                          (success-response result))))))
            (error-response "User ID, level ID, and solution required")))
    (error (e)
      (format t "Submit solution error: ~a~%" e)
      (error-response (format nil "Submission failed: ~a" e)))))

;; Get user progress
(define-easy-handler (get-progress :uri "/api/progress") (user-id)
  (add-cors-headers)
  (if user-id
      (success-response (get-user-progress (parse-integer user-id)))
      (error-response "User ID required")))

;; Get leaderboard for a level
(define-easy-handler (get-leaderboard :uri "/api/leaderboard") (level-id)
  (add-cors-headers)
  (if level-id
      (success-response (get-level-leaderboard (parse-integer level-id)))
      (error-response "Level ID required")))

;; Get user's scores
(define-easy-handler (get-scores :uri "/api/scores") (user-id level-id)
  (add-cors-headers)
  (if user-id
      (success-response (get-user-scores (parse-integer user-id)
                                        (when level-id (parse-integer level-id))))
      (error-response "User ID required")))

(defun setup-routes ()
  "Setup is done by define-easy-handler"
  (format t "Routes configured~%"))
