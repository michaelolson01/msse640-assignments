(defpackage :testcraft.models.user
  (:use :cl)
  (:import-from :testcraft.database
                :execute-query
                :execute-non-query)
  (:export :get-user-progress
           :update-user-progress))

(in-package :testcraft.models.user)

(defun get-user-progress (user-id)
  "Get all progress for a user"
  (let ((results (execute-query
                  "SELECT level_id, completed, best_score, attempts 
                   FROM user_progress WHERE user_id = ?"
                  user-id)))
    (mapcar (lambda (row)
              `((:level-id . ,(first row))
                (:completed . ,(second row))
                (:best-score . ,(third row))
                (:attempts . ,(fourth row))))
            results)))

(defun update-user-progress (user-id level-id score)
  "Update user progress for a level"
  (let ((existing (execute-query
                   "SELECT best_score, attempts FROM user_progress 
                    WHERE user_id = ? AND level_id = ?"
                   user-id level-id)))
    (if existing
        ;; Update existing progress
        (let* ((row (car existing))
               (best-score (first row))
               (attempts (second row))
               (new-best (max score best-score))
               (completed (if (>= score 100) 1 0)))
          (execute-non-query
           "UPDATE user_progress 
            SET best_score = ?, attempts = ?, completed = ?,
                completed_at = CASE WHEN ? = 1 THEN CURRENT_TIMESTAMP ELSE completed_at END
            WHERE user_id = ? AND level_id = ?"
           new-best (1+ attempts) completed completed user-id level-id))
        ;; Insert new progress
        (execute-non-query
         "INSERT INTO user_progress (user_id, level_id, best_score, attempts, completed)
          VALUES (?, ?, ?, 1, ?)"
         user-id level-id score (if (>= score 100) 1 0)))))
