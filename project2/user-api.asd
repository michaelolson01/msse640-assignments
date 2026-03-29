(asdf:defsystem #:user-api
  :description "User management API server with SQLite3 database"
  :author "Your Name"
  :license "MIT"
  :depends-on (#:hunchentoot
               #:cl-json
               #:sqlite)
  :components ((:file "user-server")))
