(defpackage :testcraft.models.level
  (:use :cl :mito)
  (:import-from :testcraft.database
                :level)
  (:export :get-all-levels
           :get-level-by-id
           :get-levels-by-chapter))

(in-package :testcraft.models.level)

(defun level-to-alist (level)
  "Convert a level DAO object to an alist with camelCase keys"
  `((:id . ,(mito:object-id level))
    (:chapter . ,(slot-value level 'testcraft.database::chapter))
    (:level-number . ,(slot-value level 'testcraft.database::level-number))
    (:title . ,(slot-value level 'testcraft.database::title))
    (:description . ,(slot-value level 'testcraft.database::description))
    (:level-type . ,(slot-value level 'testcraft.database::level-type))
    (:difficulty . ,(slot-value level 'testcraft.database::difficulty))
    (:config . ,(cl-json:decode-json-from-string 
                 (or (slot-value level 'testcraft.database::config) "{}")))
    (:solution . ,(cl-json:decode-json-from-string 
                   (or (slot-value level 'testcraft.database::solution) "{}")))
    ;; Add camelCase versions for frontend compatibility
    (:level-number . ,(slot-value level 'testcraft.database::level-number))
    (:level-type . ,(slot-value level 'testcraft.database::level-type))))

(defun get-all-levels ()
  "Get all levels"
  (let ((levels (mito:select-dao 'level
                  (sxql:order-by :chapter :level-number))))
    (mapcar #'level-to-alist levels)))

(defun get-level-by-id (level-id)
  "Get a specific level by ID"
  (let ((level (mito:find-dao 'level :id level-id)))
    (when level
      (level-to-alist level))))

(defun get-levels-by-chapter (chapter)
  "Get all levels in a chapter"
  (let ((levels (mito:select-dao 'level
                  (sxql:where (:= :chapter chapter))
                  (sxql:order-by :level-number))))
    (mapcar #'level-to-alist levels)))
