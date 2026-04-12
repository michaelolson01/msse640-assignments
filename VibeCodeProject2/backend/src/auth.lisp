(defpackage :testcraft.auth
  (:use :cl)
  (:import-from :testcraft.database
                :execute-query
                :execute-non-query
                :query-one)
  (:import-from :testcraft.utils
                :hash-password
                :verify-password
                :generate-token)
  (:export :register-user
           :authenticate-user
           :get-user-by-id))

(in-package :testcraft.auth)

(defun register-user (username password &optional email)
  "Register a new user"
  (handler-case
      (progn
        (execute-non-query
         "INSERT INTO users (username, password_hash, email) VALUES (?, ?, ?)"
         username
         (hash-password password)
         (or email ""))
        (let ((user-id (query-one "SELECT last_insert_rowid()")))
          `((:id . ,user-id)
            (:username . ,username)
            (:email . ,email))))
    (error (e)
      (format t "Error registering user: ~a~%" e)
      nil)))

(defun authenticate-user (username password)
  "Authenticate a user and return user info"
  (let ((result (execute-query
                 "SELECT id, username, password_hash, email FROM users WHERE username = ?"
                 username)))
    (when result
      (let* ((row (car result))
             (user-id (first row))
             (user-name (second row))
             (password-hash (third row))
             (email (fourth row)))
        (when (verify-password password password-hash)
          `((:id . ,user-id)
            (:username . ,user-name)
            (:email . ,email)
            (:token . ,(generate-token user-id))))))))

(defun get-user-by-id (user-id)
  "Get user by ID"
  (let ((result (execute-query
                 "SELECT id, username, email FROM users WHERE id = ?"
                 user-id)))
    (when result
      (let* ((row (car result)))
        `((:id . ,(first row))
          (:username . ,(second row))
          (:email . ,(third row)))))))
