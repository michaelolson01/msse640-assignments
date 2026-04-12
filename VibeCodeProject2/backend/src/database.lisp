(defpackage :testcraft.database
  (:use :cl :mito)
  (:export :init-db
           :user
           :level
           :user-progress
           :score))

(in-package :testcraft.database)

;; Define models
(mito:deftable user ()
  ((username :col-type (:varchar 255)
             :unique t
             :not-null t)
   (password-hash :col-type :text
                  :not-null t)
   (email :col-type (:varchar 255))))

(mito:deftable level ()
  ((chapter :col-type :integer
            :not-null t)
   (level-number :col-type :integer
                 :not-null t)
   (title :col-type (:varchar 255)
          :not-null t)
   (description :col-type :text)
   (level-type :col-type (:varchar 50)
               :not-null t)
   (difficulty :col-type (:varchar 50))
   (config :col-type :text)
   (solution :col-type :text)))

(mito:deftable user-progress ()
  ((user-id :col-type :integer
            :not-null t)
   (level-id :col-type :integer
             :not-null t)
   (completed :col-type :boolean
              :default nil)
   (best-score :col-type :integer
               :default 0)
   (attempts :col-type :integer
             :default 0)
   (completed-at :col-type :timestamp
                 :default nil)))

(mito:deftable score ()
  ((user-id :col-type :integer
            :not-null t)
   (level-id :col-type :integer
             :not-null t)
   (score :col-type :integer
          :not-null t)
   (completeness :col-type :integer)
   (efficiency :col-type :integer)
   (time-bonus :col-type :integer)
   (accuracy :col-type :integer)
   (submitted-at :col-type :timestamp
                 :default (:raw "CURRENT_TIMESTAMP"))))

(defun init-db ()
  "Initialize database connection and create tables if needed"
  (uiop:ensure-all-directories-exist (list "data/"))
  
  ;; Connect to SQLite database
  (mito:connect-toplevel :sqlite3 :database-name "data/testcraft.db")
  
  ;; Create tables
  (mito:ensure-table-exists 'user)
  (mito:ensure-table-exists 'level)
  (mito:ensure-table-exists 'user-progress)
  (mito:ensure-table-exists 'score)
  
  ;; Insert sample levels if none exist
  (when (= 0 (length (mito:select-dao 'level)))
    (insert-sample-levels))
  
  (format t "Database initialized successfully~%"))

(defun insert-sample-levels ()
  "Insert sample levels for testing"
  ;; Chapter 1, Level 1: Simple decision table
  (mito:create-dao 'level
    :chapter 1
    :level-number 1
    :title "Email Notification System"
    :description "Create a decision table for an email notification system. Consider if the user is logged in and if they are a premium member."
    :level-type "decision_table"
    :difficulty "easy"
    :config "{\"conditions\":[{\"id\":\"logged_in\",\"name\":\"User logged in?\",\"type\":\"boolean\"},{\"id\":\"premium\",\"name\":\"Premium member?\",\"type\":\"boolean\"}],\"actions\":[{\"id\":\"send_email\",\"name\":\"Send email notification\"},{\"id\":\"show_popup\",\"name\":\"Show popup notification\"}]}"
    :solution "{\"rules\":[{\"conditions\":{\"logged_in\":\"true\",\"premium\":\"true\"},\"actions\":{\"send_email\":true,\"show_popup\":true}},{\"conditions\":{\"logged_in\":\"true\",\"premium\":\"false\"},\"actions\":{\"send_email\":true,\"show_popup\":false}},{\"conditions\":{\"logged_in\":\"false\",\"premium\":\"na\"},\"actions\":{\"send_email\":false,\"show_popup\":true}}]}")
  
  ;; Chapter 1, Level 2
  (mito:create-dao 'level
    :chapter 1
    :level-number 2
    :title "ATM Withdrawal Rules"
    :description "Create a decision table for ATM withdrawal validation. Consider account balance, daily limit, and card type."
    :level-type "decision_table"
    :difficulty "medium"
    :config "{\"conditions\":[{\"id\":\"sufficient_balance\",\"name\":\"Sufficient balance?\",\"type\":\"boolean\"},{\"id\":\"within_daily_limit\",\"name\":\"Within daily limit?\",\"type\":\"boolean\"},{\"id\":\"card_active\",\"name\":\"Card active?\",\"type\":\"boolean\"}],\"actions\":[{\"id\":\"approve\",\"name\":\"Approve withdrawal\"},{\"id\":\"deny\",\"name\":\"Deny withdrawal\"},{\"id\":\"notify_bank\",\"name\":\"Notify bank\"}]}"
    :solution "{\"rules\":[{\"conditions\":{\"sufficient_balance\":\"true\",\"within_daily_limit\":\"true\",\"card_active\":\"true\"},\"actions\":{\"approve\":true,\"deny\":false,\"notify_bank\":false}},{\"conditions\":{\"sufficient_balance\":\"false\",\"within_daily_limit\":\"na\",\"card_active\":\"true\"},\"actions\":{\"approve\":false,\"deny\":true,\"notify_bank\":false}},{\"conditions\":{\"sufficient_balance\":\"true\",\"within_daily_limit\":\"false\",\"card_active\":\"true\"},\"actions\":{\"approve\":false,\"deny\":true,\"notify_bank\":true}},{\"conditions\":{\"sufficient_balance\":\"na\",\"within_daily_limit\":\"na\",\"card_active\":\"false\"},\"actions\":{\"approve\":false,\"deny\":true,\"notify_bank\":true}}]}")
  
  ;; Chapter 2, Level 1: Simple pairwise
  (mito:create-dao 'level
    :chapter 2
    :level-number 1
    :title "Browser Testing"
    :description "Create a minimal pairwise test set for a web application. Test across different browsers and operating systems."
    :level-type "pairwise"
    :difficulty "easy"
    :config "{\"parameters\":[{\"id\":\"browser\",\"name\":\"Browser\",\"values\":[\"Chrome\",\"Firefox\",\"Safari\"]},{\"id\":\"os\",\"name\":\"Operating System\",\"values\":[\"Windows\",\"macOS\",\"Linux\"]}]}"
    :solution "{\"minTests\":3,\"optimalTests\":4,\"requiredCoverage\":100}")
  
  (format t "Sample levels inserted~%"))
