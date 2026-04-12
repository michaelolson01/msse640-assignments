;;;; Startup script for TestCraft Academy

;; Ensure ASDF is loaded
(require :asdf)

;; Add current directory to ASDF source registry so it can find testcraft.asd
(push (uiop:getcwd) asdf:*central-registry*)

;; Load the system using quicklisp
(ql:quickload :testcraft)

(format t "~%====================================~%")
(format t "TestCraft Academy Backend~%")
(format t "====================================~%~%")

;; Start the server
(testcraft.main:start-server :port 8080)

;; Keep the server running
(loop (sleep 1))
