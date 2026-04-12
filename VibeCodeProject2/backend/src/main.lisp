(defpackage :testcraft.main
  (:use :cl :hunchentoot)
  (:import-from :testcraft.database
                :init-db)
  (:import-from :testcraft.routes
                :setup-routes)
  (:export :start-server
           :stop-server
           :*server*))

(in-package :testcraft.main)

(defvar *server* nil "The Hunchentoot server instance")

(defun start-server (&key (port 8080))
  "Start the TestCraft Academy server"
  (format t "~%=== TestCraft Academy Server ===~%")
  
  ;; Initialize database
  (format t "Initializing database...~%")
  (init-db)
  
  ;; Setup routes
  (format t "Setting up routes...~%")
  (setup-routes)
  
  ;; Start web server
  (format t "Starting server on port ~a...~%" port)
  (setf *server* (make-instance 'easy-acceptor :port port))
  (start *server*)
  
  (format t "~%Server running at http://localhost:~a~%" port)
  (format t "API endpoints:~%")
  (format t "  POST /api/register~%")
  (format t "  POST /api/login~%")
  (format t "  GET  /api/levels~%")
  (format t "  GET  /api/level?id=<id>~%")
  (format t "  POST /api/submit~%")
  (format t "  GET  /api/progress?user-id=<id>~%")
  (format t "  GET  /api/leaderboard?level-id=<id>~%")
  (format t "  GET  /api/scores?user-id=<id>~%")
  (format t "~%Press Ctrl+C to stop~%~%"))

(defun stop-server ()
  "Stop the server"
  (when *server*
    (stop *server*)
    (setf *server* nil)
    (format t "Server stopped~%")))

;; Allow reloading without restarting
(defun restart-server (&key (port 8080))
  "Restart the server"
  (stop-server)
  (sleep 1)
  (start-server :port port))
