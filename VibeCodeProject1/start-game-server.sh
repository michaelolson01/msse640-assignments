#!/bin/bash 

echo --- Starting Game Server ---

sbcl --load testing-game.asd --eval "(ql:quickload :testing-game)" --eval "(testing-game:start-server)" --eval "(sb-thread:join-thread (find-if (lambda (th) (search \"hunchentoot\" (sb-thread:thread-name th))) (sb-thread:list-all-threads)))"

echo --- Game Server Finished ---
