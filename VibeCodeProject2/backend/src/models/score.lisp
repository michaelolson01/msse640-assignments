(defpackage :testcraft.models.score
  (:use :cl)
  (:import-from :testcraft.database
                :execute-query
                :execute-non-query
                :query-one)
  (:export :save-score
           :get-user-scores
           :get-level-leaderboard))

(in-package :testcraft.models.score)

(defun save-score (user-id level-id score completeness efficiency time-bonus accuracy)
  "Save a score to the database"
  (execute-non-query
   "INSERT INTO scores (user_id, level_id, score, completeness, efficiency, time_bonus, accuracy)
    VALUES (?, ?, ?, ?, ?, ?, ?)"
   user-id level-id score completeness efficiency time-bonus accuracy)
  (query-one "SELECT last_insert_rowid()"))

(defun get-user-scores (user-id &optional level-id)
  "Get scores for a user, optionally filtered by level"
  (let ((results
          (if level-id
              (execute-query
               "SELECT id, level_id, score, completeness, efficiency, time_bonus, accuracy, submitted_at
                FROM scores WHERE user_id = ? AND level_id = ? ORDER BY submitted_at DESC"
               user-id level-id)
              (execute-query
               "SELECT id, level_id, score, completeness, efficiency, time_bonus, accuracy, submitted_at
                FROM scores WHERE user_id = ? ORDER BY submitted_at DESC"
               user-id))))
    (mapcar (lambda (row)
              `((:id . ,(first row))
                (:level-id . ,(second row))
                (:score . ,(third row))
                (:completeness . ,(fourth row))
                (:efficiency . ,(fifth row))
                (:time-bonus . ,(sixth row))
                (:accuracy . ,(seventh row))
                (:submitted-at . ,(eighth row))))
            results)))

(defun get-level-leaderboard (level-id &optional (limit 10))
  "Get top scores for a level"
  (let ((results (execute-query
                  "SELECT u.username, s.score, s.submitted_at
                   FROM scores s
                   JOIN users u ON s.user_id = u.id
                   WHERE s.level_id = ?
                   ORDER BY s.score DESC, s.submitted_at ASC
                   LIMIT ?"
                  level-id limit)))
    (mapcar (lambda (row)
              `((:username . ,(first row))
                (:score . ,(second row))
                (:submitted-at . ,(third row))))
            results)))
