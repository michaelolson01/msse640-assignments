(defpackage :testcraft.database
  (:use :cl :sqlite)
  (:export :*db*
           :init-db
           :execute-query
           :execute-non-query
           :query-one
           :query-all))

(in-package :testcraft.database)

(defvar *db* nil "Database connection")
(defvar *db-path* "data/testcraft.db")

(defun init-db ()
  "Initialize database connection and create tables if needed"
  (ensure-directories-exist "data/")
  (setf *db* (sqlite:connect *db-path*))
  (create-tables))

(defun create-tables ()
  "Create database tables if they don't exist"
  ;; Users table
  (sqlite:execute-non-query *db*
    "CREATE TABLE IF NOT EXISTS users (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       username TEXT UNIQUE NOT NULL,
       password_hash TEXT NOT NULL,
       email TEXT,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
     )")
  
  ;; Levels table
  (sqlite:execute-non-query *db*
    "CREATE TABLE IF NOT EXISTS levels (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       chapter INTEGER NOT NULL,
       level_number INTEGER NOT NULL,
       title TEXT NOT NULL,
       description TEXT,
       level_type TEXT NOT NULL,
       difficulty TEXT,
       config TEXT,
       solution TEXT,
       UNIQUE(chapter, level_number)
     )")
  
  ;; User progress table
  (sqlite:execute-non-query *db*
    "CREATE TABLE IF NOT EXISTS user_progress (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       user_id INTEGER NOT NULL,
       level_id INTEGER NOT NULL,
       completed BOOLEAN DEFAULT 0,
       best_score INTEGER DEFAULT 0,
       attempts INTEGER DEFAULT 0,
       completed_at TIMESTAMP,
       FOREIGN KEY (user_id) REFERENCES users(id),
       FOREIGN KEY (level_id) REFERENCES levels(id),
       UNIQUE(user_id, level_id)
     )")
  
  ;; Scores table
  (sqlite:execute-non-query *db*
    "CREATE TABLE IF NOT EXISTS scores (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       user_id INTEGER NOT NULL,
       level_id INTEGER NOT NULL,
       score INTEGER NOT NULL,
       completeness INTEGER,
       efficiency INTEGER,
       time_bonus INTEGER,
       accuracy INTEGER,
       submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       FOREIGN KEY (user_id) REFERENCES users(id),
       FOREIGN KEY (level_id) REFERENCES levels(id)
     )")
  
  ;; Create indexes
  (sqlite:execute-non-query *db*
    "CREATE INDEX IF NOT EXISTS idx_user_progress_user ON user_progress(user_id)")
  (sqlite:execute-non-query *db*
    "CREATE INDEX IF NOT EXISTS idx_scores_user ON scores(user_id)")
  (sqlite:execute-non-query *db*
    "CREATE INDEX IF NOT EXISTS idx_scores_level ON scores(level_id)")
  
  ;; Insert sample levels if none exist
  (when (= 0 (query-one "SELECT COUNT(*) FROM levels"))
    (insert-sample-levels)))

(defun insert-sample-levels ()
  "Insert sample levels for testing"
  ;; Chapter 1, Level 1: Simple decision table
  (sqlite:execute-non-query *db*
    "INSERT INTO levels (chapter, level_number, title, description, level_type, difficulty, config, solution)
     VALUES (1, 1, 'Email Notification System', 
             'Create a decision table for an email notification system. Consider if the user is logged in and if they are a premium member.',
             'decision_table', 'easy',
             '{\"conditions\":[{\"id\":\"logged_in\",\"name\":\"User logged in?\",\"type\":\"boolean\"},{\"id\":\"premium\",\"name\":\"Premium member?\",\"type\":\"boolean\"}],\"actions\":[{\"id\":\"send_email\",\"name\":\"Send email notification\"},{\"id\":\"show_popup\",\"name\":\"Show popup notification\"}]}',
             '{\"rules\":[{\"conditions\":{\"logged_in\":\"true\",\"premium\":\"true\"},\"actions\":{\"send_email\":true,\"show_popup\":true}},{\"conditions\":{\"logged_in\":\"true\",\"premium\":\"false\"},\"actions\":{\"send_email\":true,\"show_popup\":false}},{\"conditions\":{\"logged_in\":\"false\",\"premium\":\"na\"},\"actions\":{\"send_email\":false,\"show_popup\":true}}]}')")
  
  ;; Chapter 1, Level 2
  (sqlite:execute-non-query *db*
    "INSERT INTO levels (chapter, level_number, title, description, level_type, difficulty, config, solution)
     VALUES (1, 2, 'ATM Withdrawal Rules', 
             'Create a decision table for ATM withdrawal validation. Consider account balance, daily limit, and card type.',
             'decision_table', 'medium',
             '{\"conditions\":[{\"id\":\"sufficient_balance\",\"name\":\"Sufficient balance?\",\"type\":\"boolean\"},{\"id\":\"within_daily_limit\",\"name\":\"Within daily limit?\",\"type\":\"boolean\"},{\"id\":\"card_active\",\"name\":\"Card active?\",\"type\":\"boolean\"}],\"actions\":[{\"id\":\"approve\",\"name\":\"Approve withdrawal\"},{\"id\":\"deny\",\"name\":\"Deny withdrawal\"},{\"id\":\"notify_bank\",\"name\":\"Notify bank\"}]}',
             '{\"rules\":[{\"conditions\":{\"sufficient_balance\":\"true\",\"within_daily_limit\":\"true\",\"card_active\":\"true\"},\"actions\":{\"approve\":true,\"deny\":false,\"notify_bank\":false}},{\"conditions\":{\"sufficient_balance\":\"false\",\"within_daily_limit\":\"na\",\"card_active\":\"true\"},\"actions\":{\"approve\":false,\"deny\":true,\"notify_bank\":false}},{\"conditions\":{\"sufficient_balance\":\"true\",\"within_daily_limit\":\"false\",\"card_active\":\"true\"},\"actions\":{\"approve\":false,\"deny\":true,\"notify_bank\":true}},{\"conditions\":{\"sufficient_balance\":\"na\",\"within_daily_limit\":\"na\",\"card_active\":\"false\"},\"actions\":{\"approve\":false,\"deny\":true,\"notify_bank\":true}}]}')")
  
  ;; Chapter 2, Level 1: Simple pairwise
  (sqlite:execute-non-query *db*
    "INSERT INTO levels (chapter, level_number, title, description, level_type, difficulty, config, solution)
     VALUES (2, 1, 'Browser Testing', 
             'Create a minimal pairwise test set for a web application. Test across different browsers and operating systems.',
             'pairwise', 'easy',
             '{\"parameters\":[{\"id\":\"browser\",\"name\":\"Browser\",\"values\":[\"Chrome\",\"Firefox\",\"Safari\"]},{\"id\":\"os\",\"name\":\"Operating System\",\"values\":[\"Windows\",\"macOS\",\"Linux\"]}]}',
             '{\"minTests\":3,\"optimalTests\":4,\"requiredCoverage\":100}')")
  
  (format t "Sample levels inserted~%"))

(defun execute-query (sql &rest params)
  "Execute a SELECT query and return results"
  (apply #'sqlite:execute-to-list *db* sql params))

(defun execute-non-query (sql &rest params)
  "Execute an INSERT/UPDATE/DELETE query"
  (apply #'sqlite:execute-non-query *db* sql params))

(defun query-one (sql &rest params)
  "Execute query and return first result"
  (let ((results (apply #'execute-query sql params)))
    (when results
      (caar results))))

(defun query-all (sql &rest params)
  "Execute query and return all results"
  (apply #'execute-query sql params))
