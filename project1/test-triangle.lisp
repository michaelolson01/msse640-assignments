(ql:quickload :fiveam :silent t)

(defpackage :triangle-test
  (:use :cl :fiveam))

(in-package :triangle-test)

;; Load the triangle code
(load "triangle.lisp")

;; Define the test suite
(def-suite triangle-tests
  :description "Test suite for triangle classification")

(in-suite triangle-tests)

;; Test equilateral triangles
(test equilateral-triangle
  "Test that equilateral triangles are correctly identified"
  (is (string= "Equilateral triangle" (classify-triangle 5 5 5)))
  (is (string= "Equilateral triangle" (classify-triangle 10 10 10)))
  (is (string= "Equilateral triangle" (classify-triangle 1.5 1.5 1.5))))

;; Test isosceles triangles
(test isosceles-triangle
  "Test that isosceles triangles are correctly identified"
  (is (string= "Isosceles triangle" (classify-triangle 12 12 13)))
  (is (string= "Isosceles triangle" (classify-triangle 5 5 7)))
  (is (string= "Isosceles triangle" (classify-triangle 5 7 5)))
  (is (string= "Isosceles triangle" (classify-triangle 7 5 5)))
  (is (string= "Isosceles triangle" (classify-triangle #C(7 0) 5 5))))

;; Test scalene triangles
(test scalene-triangle
  "Test that scalene triangles are correctly identified"
  (is (string= "Scalene triangle" (classify-triangle 3 4 5)))
  (is (string= "Scalene triangle" (classify-triangle 5 7 9)))
  (is (string= "Scalene triangle" (classify-triangle 2.5 3.5 4.5))))

;; Test invalid inputs (non-positive sides)
(test invalid-sides
  "Test that non-positive sides are rejected"
  (is (string= "Invalid: All sides must be positive numbers" (classify-triangle 0 5 5)))
  (is (string= "Invalid: All sides must be positive numbers" (classify-triangle 5 0 5)))
  (is (string= "Invalid: All sides must be positive numbers" (classify-triangle 5 5 0)))
  (is (string= "Invalid: All sides must be positive numbers" (classify-triangle -1 5 5)))
  (is (string= "Invalid: All sides must be positive numbers" (classify-triangle 5 -1 5)))
  (is (string= "Invalid: All sides must be positive numbers" (classify-triangle 5 5 -1))))

;; Test triangle inequality violations
(test triangle-inequality
  "Test that sides not satisfying triangle inequality are rejected"
  (is (string= "Not a triangle: Does not satisfy triangle inequality" (classify-triangle 1 2 5)))
  (is (string= "Not a triangle: Does not satisfy triangle inequality" (classify-triangle 1 5 2)))
  (is (string= "Not a triangle: Does not satisfy triangle inequality" (classify-triangle 5 1 2)))
  (is (string= "Not a triangle: Does not satisfy triangle inequality" (classify-triangle 1 2 3)))
  (is (string= "Not a triangle: Does not satisfy triangle inequality" (classify-triangle 10 5 3))))

;; Test non-numeric inputs
(test non-numeric-inputs
  "Test that non-numeric inputs are rejected"
  (is (string= "Invalid: All sides must be numbers" (classify-triangle "abc" 5 5)))
  (is (string= "Invalid: All sides must be numbers" (classify-triangle 5 "xyz" 5)))
  (is (string= "Invalid: All sides must be numbers" (classify-triangle 5 5 "test")))
  (is (string= "Invalid: All sides must be numbers" (classify-triangle 'symbol 5 5)))
  (is (string= "Invalid: All sides must be numbers" (classify-triangle 5 'another 5)))
  (is (string= "Invalid: All sides must be numbers" (classify-triangle 5 5 'third)))
  (is (string= "Invalid: All sides must be numbers" (classify-triangle nil 5 5)))
  (is (string= "Invalid: All sides must be numbers" (classify-triangle 5 nil 5)))
  (is (string= "Invalid: All sides must be numbers" (classify-triangle 5 5 nil))))

;; Test complex number inputs
(test complex-number-inputs
  "Test that complex numbers are rejected"
  (is (string= "Invalid: Complex numbers are not allowed" (classify-triangle #C(1 1) 5 5)))
  (is (string= "Invalid: Complex numbers are not allowed" (classify-triangle 5 #C(2 3) 5)))
  (is (string= "Invalid: Complex numbers are not allowed" (classify-triangle 5 5 #C(4 5))))
  (is (string= "Invalid: Complex numbers are not allowed" (classify-triangle #C(0 1) #C(0 1) 5))))

;; Run all tests
(format t "~%Running triangle classification tests...~%")
(run! 'triangle-tests)

(in-package :cl-user)
;; Exit
(quit)
