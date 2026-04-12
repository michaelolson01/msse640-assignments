(defpackage :testcraft.validators.decision-table
  (:use :cl)
  (:export :validate-decision-table
           :calculate-score))

(in-package :testcraft.validators.decision-table)

(defun validate-decision-table (user-solution solution-data)
  "Validate user's decision table against solution"
  (let* ((user-rules (cdr (assoc :rules user-solution)))
         (solution-rules (cdr (assoc :rules solution-data)))
         (completeness (calculate-completeness user-rules solution-rules))
         (efficiency (calculate-efficiency user-rules solution-rules))
         (accuracy (calculate-accuracy user-rules solution-rules)))
    `((:completeness . ,completeness)
      (:efficiency . ,efficiency)
      (:accuracy . ,accuracy)
      (:total . ,(+ completeness efficiency accuracy)))))

(defun calculate-completeness (user-rules solution-rules)
  "Calculate completeness score (0-100)"
  ;; Check if user covers all required scenarios
  (let ((required-scenarios (extract-scenarios solution-rules))
        (user-scenarios (extract-scenarios user-rules)))
    (if (null required-scenarios)
        100
        (let ((covered (count-if (lambda (req-scenario)
                                   (member req-scenario user-scenarios :test #'scenario-equal))
                                 required-scenarios)))
          (round (* 100 (/ covered (length required-scenarios))))))))

(defun calculate-efficiency (user-rules solution-rules)
  "Calculate efficiency score (0-50)"
  ;; Penalize redundant rules
  (let ((expected-rules (length solution-rules))
        (user-rule-count (length user-rules)))
    (cond
      ((= user-rule-count expected-rules) 50)
      ((< user-rule-count expected-rules) 30) ; Missing rules
      ((> user-rule-count (* 2 expected-rules)) 10) ; Too many redundant rules
      (t (max 20 (round (* 50 (/ expected-rules user-rule-count))))))))

(defun calculate-accuracy (user-rules solution-rules)
  "Calculate accuracy score (0-20)"
  ;; Check if actions are correct for each scenario
  (let ((correct-count 0)
        (total-count 0))
    (dolist (user-rule user-rules)
      (incf total-count)
      (when (find-if (lambda (sol-rule)
                       (rule-matches user-rule sol-rule))
                     solution-rules)
        (incf correct-count)))
    (if (zerop total-count)
        0
        (round (* 20 (/ correct-count total-count))))))

(defun extract-scenarios (rules)
  "Extract condition patterns from rules"
  (mapcar (lambda (rule)
            (cdr (assoc :conditions rule)))
          rules))

(defun scenario-equal (scenario1 scenario2)
  "Check if two scenarios are equal (works with alists)"
  (and (= (length scenario1) (length scenario2))
       (every (lambda (pair)
                (equal (cdr pair)
                       (cdr (assoc (car pair) scenario2 :test #'equal))))
              scenario1)))

(defun rule-matches (user-rule solution-rule)
  "Check if user rule matches solution rule"
  (let ((user-conditions (cdr (assoc :conditions user-rule)))
        (user-actions (cdr (assoc :actions user-rule)))
        (sol-conditions (cdr (assoc :conditions solution-rule)))
        (sol-actions (cdr (assoc :actions solution-rule))))
    (and (scenario-equal user-conditions sol-conditions)
         (actions-equal user-actions sol-actions))))

(defun actions-equal (actions1 actions2)
  "Check if two action sets are equal (works with alists)"
  (and (= (length actions1) (length actions2))
       (every (lambda (pair)
                (equal (cdr pair)
                       (cdr (assoc (car pair) actions2 :test #'equal))))
              actions1)))
