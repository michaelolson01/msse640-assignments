;;;; Startup script for TestCraft Academy
(load "testcraft.asd")
(ql:quickload :testcraft)

(format t "~%====================================~%")
(format t "TestCraft Academy Backend~%")
(format t "====================================~%~%")

;; Start the server
(testcraft.main:start-server :port 8080)

;; Keep the server running
(loop (sleep 1))
