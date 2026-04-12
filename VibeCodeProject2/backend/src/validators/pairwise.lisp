(defpackage :testcraft.validators.pairwise
  (:use :cl)
  (:export :validate-pairwise
           :calculate-coverage))

(in-package :testcraft.validators.pairwise)

(defun validate-pairwise (user-tests solution-data parameters-data)
  "Validate pairwise test set"
  (let* ((parameters (cdr (assoc :parameters parameters-data)))
         (coverage (calculate-coverage user-tests parameters))
         (min-tests (cdr (assoc :min-tests solution-data)))
         (optimal-tests (cdr (assoc :optimal-tests solution-data)))
         (test-count (length user-tests))
         (completeness (min 100 coverage))
         (efficiency (calculate-test-efficiency test-count optimal-tests))
         (accuracy 20)) ; Full accuracy if coverage is good
    `((:completeness . ,completeness)
      (:efficiency . ,efficiency)
      (:accuracy . ,accuracy)
      (:coverage . ,coverage)
      (:test-count . ,test-count)
      (:total . ,(+ completeness efficiency accuracy)))))

(defun calculate-coverage (test-cases parameters)
  "Calculate percentage of pairs covered"
  (let* ((all-pairs (generate-all-pairs parameters))
         (covered-pairs (find-covered-pairs test-cases all-pairs)))
    (if (zerop (length all-pairs))
        100
        (round (* 100 (/ (length covered-pairs) (length all-pairs)))))))

(defun generate-all-pairs (parameters)
  "Generate all possible parameter pairs"
  (let ((pairs nil))
    (loop for i from 0 below (length parameters)
          do (loop for j from (1+ i) below (length parameters)
                   do (let* ((param1 (nth i parameters))
                             (param2 (nth j parameters))
                             (param1-id (cdr (assoc :id param1)))
                             (param2-id (cdr (assoc :id param2)))
                             (param1-values (cdr (assoc :values param1)))
                             (param2-values (cdr (assoc :values param2))))
                        (dolist (val1 param1-values)
                          (dolist (val2 param2-values)
                            (push (list (cons param1-id val1)
                                       (cons param2-id val2))
                                  pairs))))))
    (nreverse pairs)))

(defun find-covered-pairs (test-cases all-pairs)
  "Find which pairs are covered by test cases"
  (remove-duplicates
   (loop for test in test-cases
         append (loop for pair in all-pairs
                      when (pair-covered-by-test pair test)
                      collect pair))
   :test #'equal))

(defun pair-covered-by-test (pair test)
  "Check if a pair is covered by a test case"
  (every (lambda (param-value)
           (let* ((param-id (car param-value))
                  (value (cdr param-value))
                  (test-value (cdr (assoc param-id test :test #'equal))))
             (equal value test-value)))
         pair))

(defun calculate-test-efficiency (test-count optimal-count)
  "Calculate efficiency based on test count vs optimal"
  (cond
    ((<= test-count optimal-count) 50)
    ((<= test-count (* 1.5 optimal-count)) 40)
    ((<= test-count (* 2 optimal-count)) 30)
    (t 20)))
