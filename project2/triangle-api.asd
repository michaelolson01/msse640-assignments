(asdf:defsystem #:triangle-api
  :description "Triangle classification API server using Hunchentoot"
  :author "Your Name"
  :license "MIT"
  :depends-on (#:hunchentoot
               #:cl-json)
  :components ((:file "triangle-server")))
