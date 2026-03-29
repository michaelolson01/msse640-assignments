#!/bin/bash

echo --- Starting Triangle Server ---

sbcl --load project2/triangle-api.asd --eval "(ql:quickload :triangle-api)" --eval "(triangle-api:start-server)" --eval "(sb-thread:join-thread (find-if (lambda (th) (search \"hunchentoot\" (sb-thread:thread-name th))) (sb-thread:list-all-threads)))"

echo --- Triangle Server has stopped ---

