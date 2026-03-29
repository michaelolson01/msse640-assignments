#!/bin/bash

echo --- Starting User Server ---

# sbcl --eval "(ql:quickload :user-api)" --eval "(user-api:start-server)"
sbcl --load project2/user-api.asd --eval "(ql:quickload :user-api)" --eval "(user-api:start-server)" --eval "(sb-thread:join-thread (find-if (lambda (th) (search \"hunchentoot\" (sb-thread:thread-name th))) (sb-thread:list-all-threads)))"

echo --- User Server has stopped ---
