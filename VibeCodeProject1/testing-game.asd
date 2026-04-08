(asdf:defsystem #:testing-game
  :description "Web-based game for learning equivalence class and boundary testing"
  :author "Your Name"
  :license "MIT"
  :depends-on (#:hunchentoot
               #:cl-json)
  :components ((:file "server")))
