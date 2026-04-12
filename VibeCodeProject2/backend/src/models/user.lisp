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
        (mito:create-dao 'user-progress
          :user-id user-id
          :level-id level-id
          :best-score score
          :attempts 1
          :completed (if (>= score 100) t nil)
          :completed-at (when (>= score 100) (local-time:now))))))
