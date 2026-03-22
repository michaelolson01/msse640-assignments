(defun classify-triangle (a b c)
  "Classify a triangle based on the lengths of its sides.

   Args:
     a, b, c: The lengths of the three sides

   Returns:
     A string describing the triangle type"
  (cond
   ;; Check if inputs are numbers
   ((not (numberp a)) "Invalid: All sides must be numbers")
   ((not (numberp b)) "Invalid: All sides must be numbers")
   ((not (numberp c)) "Invalid: All sides must be numbers")
   ;; Check if inputs are complex numbers
   ((complexp a) "Invalid: Complex numbers are not allowed")
   ((complexp b) "Invalid: Complex numbers are not allowed")
   ((complexp c) "Invalid: Complex numbers are not allowed")
   ;; Check if all sides are positive
   ((<= a 0) "Invalid: All sides must be positive numbers")
   ((<= b 0) "Invalid: All sides must be positive numbers")
   ((<= c 0) "Invalid: All sides must be positive numbers")
   ;; Check triangle inequality
   ((<= (+ a b) c) "Not a triangle: Does not satisfy triangle inequality")
   ((<= (+ a c) b) "Not a triangle: Does not satisfy triangle inequality")
   ((<= (+ b c) a) "Not a triangle: Does not satisfy triangle inequality")
   ;; Classify the triangle type
   ((and (= a b) (= b c)) "Equilateral triangle")
   ((or (= a b) (= b c) (= a c)) "Isosceles triangle")
   (t "Scalene triangle")))

(defun main ()
  "Main function to get user input and classify the triangle."
  (format t "Triangle Classifier~%")
  (format t "========================================~%")

  (format t "Enter the length of side 1: ")
  (finish-output)
  (let ((a (read)))
    (format t "Enter the length of side 2: ")
    (finish-output)
    (let ((b (read)))
      (format t "Enter the length of side 3: ")
      (finish-output)
      (let ((c (read)))
        (let ((result (classify-triangle a b c)))
          (format t "~%Result: ~a~%" result))))))
