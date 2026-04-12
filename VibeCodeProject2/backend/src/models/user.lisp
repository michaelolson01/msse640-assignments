(defpackage :testcraft.models.user
  (:use :cl :mito :local-time)
  (:import-from :testcraft.database
                :user-progress)
  (:export :get-user-progress
           :update-user-progress))

(in-package :testcraft.models.user)

(defun get-user-progress (user-id)
  "Get all progress for a user"
  (let ((progress-list (mito:select-dao 'user-progress
                         (sxql:where (:= :user-id user-id)))))
    (mapcar (lambda (progress)
              `((:level-id . ,(slot-value progress 'testcraft.database::level-id))
                (:completed . ,(slot-value progress 'testcraft.database::completed))
                (:best-score . ,(slot-value progress 'testcraft.database::best-score))
                (:attempts . ,(slot-value progress 'testcraft.database::attempts))))
            progress-list)))

(defun update-user-progress (user-id level-id score completeness efficiency accuracy)
  "Update user progress for a level"
  (declare (ignore completeness efficiency accuracy))
  (let ((existing (car (mito:select-dao 'user-progress
                         (sxql:where (:and (:= :user-id user-id)
                                          (:= :level-id level-id)))))))
    (if existing
        ;; Update existing progress
        (let* ((best-score (slot-value existing 'testcraft.database::best-score))
               (attempts (slot-value existing 'testcraft.database::attempts))
               (new-best (max score best-score))
               (completed (if (>= score 100) t nil)))
          (setf (slot-value existing 'testcraft.database::best-score) new-best)
          (setf (slot-value existing 'testcraft.database::attempts) (1+ attempts))
          (setf (slot-value existing 'testcraft.database::completed) completed)
          (when completed
            (setf (slot-value existing 'testcraft.database::completed-at) (local-time:now)))
          (mito:save-dao existing))
        ;; Insert new progress
        (let ((completed-p (>= score 100)))
          (mito:create-dao 'user-progress
            :user-id user-id
            :level-id level-id
            :best-score score
            :attempts 1
            :completed completed-p
            :completed-at (when completed-p (local-time:now)))))))
(defpackage :testcraft.models.user
  (:use :cl :mito :local-time)
  (:import-from :testcraft.database
                :user-progress)
  (:export :get-user-progress
           :update-user-progress))

(in-package :testcraft.models.user)

(defun get-user-progress (user-id)
  "Get progress for a user across all levels"
  (let ((progress-list (mito:select-dao 'user-progress
                         (sxql:where (:= :user-id user-id)))))
    (mapcar (lambda (p)
              `((:level-id . ,(slot-value p 'testcraft.database::level-id))
                (:completed . ,(slot-value p 'testcraft.database::completed))
                (:best-score . ,(slot-value p 'testcraft.database::best-score))
                (:attempts . ,(slot-value p 'testcraft.database::attempts))
                (:completed-at . ,(slot-value p 'testcraft.database::completed-at))))
            progress-list)))

(defun update-user-progress (user-id level-id score completeness efficiency accuracy)
  "Update or create user progress for a level"
  (let ((existing (mito:find-dao 'user-progress
                    :user-id user-id
                    :level-id level-id)))
    (if existing
        ;; Update existing progress
        (progn
          (setf (slot-value existing 'testcraft.database::best-score)
                (max (slot-value existing 'testcraft.database::best-score) score))
          (setf (slot-value existing 'testcraft.database::attempts)
                (+ 1 (slot-value existing 'testcraft.database::attempts)))
          (when (>= score 80)
            (setf (slot-value existing 'testcraft.database::completed) t)
            (setf (slot-value existing 'testcraft.database::completed-at) (local-time:now)))
          (mito:save-dao existing))
        ;; Create new progress
        (mito:create-dao 'user-progress
          :user-id user-id
          :level-id level-id
          :completed (>= score 80)
          :best-score score
          :attempts 1
          :completed-at (if (>= score 80) (local-time:now) nil)))))
