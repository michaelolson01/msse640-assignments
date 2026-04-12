(defpackage :testcraft.auth
  (:use :cl :mito)
  (:import-from :testcraft.database
                :user)
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
      (let* ((email-value (or email ""))
             (user (mito:create-dao 'user
                     :username username
                     :password-hash (hash-password password)
                     :email email-value)))
        `((:id . ,(mito:object-id user))
          (:username . ,username)
          (:email . ,email-value)))
    (error (e)
      (format t "Error registering user: ~a~%" e)
      nil)))

(defun authenticate-user (username password)
  "Authenticate a user and return user info"
  (handler-case
      (let ((user (car (mito:select-dao 'user
                         (sxql:where (:= :username username))))))
        (when user
          (let ((password-hash (slot-value user 'testcraft.database::password-hash))
                (user-id (mito:object-id user)))
            (when (verify-password password password-hash)
              `((:id . ,user-id)
                (:username . ,(slot-value user 'testcraft.database::username))
                (:email . ,(or (slot-value user 'testcraft.database::email) ""))
                (:token . ,(generate-token user-id)))))))
    (error (e)
      (format t "Error authenticating user: ~a~%" e)
      nil)))

(defun get-user-by-id (user-id)
  "Get user by ID"
  (handler-case
      (let ((user (mito:find-dao 'user :id user-id)))
        (when user
          `((:id . ,(mito:object-id user))
            (:username . ,(slot-value user 'testcraft.database::username))
            (:email . ,(or (slot-value user 'testcraft.database::email) "")))))
    (error (e)
      (format t "Error getting user by ID: ~a~%" e)
      nil)))
