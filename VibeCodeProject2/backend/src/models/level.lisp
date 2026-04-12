(defpackage :testcraft.models.level
  (:use :cl)
  (:import-from :testcraft.database
                :execute-query)
  (:export :get-all-levels
           :get-level-by-id
           :get-levels-by-chapter))

(in-package :testcraft.models.level)

(defun parse-level-row (row)
  "Parse a level row into an alist"
  `((:id . ,(first row))
    (:chapter . ,(second row))
    (:level-number . ,(third row))
    (:title . ,(fourth row))
    (:description . ,(fifth row))
    (:level-type . ,(sixth row))
    (:difficulty . ,(seventh row))
    (:config . ,(cl-json:decode-json-from-string (eighth row)))
    (:solution . ,(cl-json:decode-json-from-string (ninth row)))))

(defun get-all-levels ()
  "Get all levels"
  (let ((results (execute-query
                  "SELECT id, chapter, level_number, title, description, 
                          level_type, difficulty, config, solution 
                   FROM levels ORDER BY chapter, level_number")))
    (mapcar #'parse-level-row results)))

(defun get-level-by-id (level-id)
  "Get a specific level by ID"
  (let ((results (execute-query
                  "SELECT id, chapter, level_number, title, description, 
                          level_type, difficulty, config, solution 
                   FROM levels WHERE id = ?"
                  level-id)))
    (when results
      (parse-level-row (car results)))))

(defun get-levels-by-chapter (chapter)
  "Get all levels in a chapter"
  (let ((results (execute-query
                  "SELECT id, chapter, level_number, title, description, 
                          level_type, difficulty, config, solution 
                   FROM levels WHERE chapter = ? ORDER BY level_number"
                  chapter)))
    (mapcar #'parse-level-row results)))
