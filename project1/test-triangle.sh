#!/usr/bin/env -S sbcl --script

;; The test uses quicklisp, so have to load that before
;; loading the testing framework.
(load "~/quicklisp/setup.lisp")
(load "test-triangle.lisp")
