(defsystem "testcraft"
  :description "TestCraft Academy - Educational game for decision tables and pairwise testing"
  :author "Your Name"
  :license "MIT"
  :depends-on (:hunchentoot
               :cl-json
               :sqlite
               :ironclad
               :cl-ppcre
               :alexandria)
  :serial t
  :components ((:module "src"
                :components
                ((:file "utils")
                 (:file "database")
                 (:file "auth")
                 (:module "models"
                  :components
                  ((:file "user")
                   (:file "level")
                   (:file "score")))
                 (:module "validators"
                  :components
                  ((:file "decision-table")
                   (:file "pairwise")))
                 (:file "routes")
                 (:file "main")))))
