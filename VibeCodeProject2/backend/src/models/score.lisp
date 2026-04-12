(defpackage :testcraft.models.score
  (:use :cl :mito :local-time)
  (:import-from :testcraft.database
                :score
                :user)
  (:export :save-score
           :get-user-scores
           :get-level-leaderboard))

(in-package :testcraft.models.score)

(defun save-score (user-id level-id score completeness efficiency time-bonus accuracy)
  "Save a score to the database"
  (mito:create-dao 'score
    :user-id user-id
    :level-id level-id
    :score score
    :completeness completeness
    :efficiency efficiency
    :time-bonus time-bonus
    :accuracy accuracy
    :submitted-at (local-time:now)))

(defun get-user-scores (user-id &optional level-id)
  "Get scores for a user, optionally filtered by level"
  (let ((scores-list
          (if level-id
              (mito:select-dao 'score
                (sxql:where (:and (:= :user-id user-id)
                                 (:= :level-id level-id)))
                (sxql:order-by (:desc :submitted-at)))
              (mito:select-dao 'score
                (sxql:where (:= :user-id user-id))
                (sxql:order-by (:desc :submitted-at))))))
    (mapcar (lambda (s)
              `((:id . ,(mito:object-id s))
                (:level-id . ,(slot-value s 'testcraft.database::level-id))
                (:score . ,(slot-value s 'testcraft.database::score))
                (:completeness . ,(slot-value s 'testcraft.database::completeness))
                (:efficiency . ,(slot-value s 'testcraft.database::efficiency))
                (:time-bonus . ,(slot-value s 'testcraft.database::time-bonus))
                (:accuracy . ,(slot-value s 'testcraft.database::accuracy))
                (:submitted-at . ,(slot-value s 'testcraft.database::submitted-at))))
            scores-list)))

(defun get-level-leaderboard (level-id &optional (limit 10))
  "Get top scores for a level"
  (let ((scores-list (mito:select-dao 'score
                       (sxql:where (:= :level-id level-id))
                       (sxql:order-by (:desc :score) (:asc :submitted-at))
                       (sxql:limit limit))))
    (mapcar (lambda (s)
              (let ((user (mito:find-dao 'user :id (slot-value s 'testcraft.database::user-id))))
                `((:username . ,(slot-value user 'testcraft.database::username))
                  (:score . ,(slot-value s 'testcraft.database::score))
                  (:submitted-at . ,(slot-value s 'testcraft.database::submitted-at)))))
            scores-list)))
