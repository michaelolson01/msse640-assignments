(defpackage :testcraft.utils
  (:use :cl)
  (:export :json-response
           :error-response
           :success-response
           :hash-password
           :verify-password
           :generate-token
           :current-timestamp))

(in-package :testcraft.utils)

(defun json-response (data)
  "Create a JSON response"
  (setf (hunchentoot:content-type*) "application/json")
  (cl-json:encode-json-to-string data))

(defun error-response (message)
  "Create an error JSON response"
  (json-response `((:success . nil)
                   (:error . ,message))))

(defun success-response (data)
  "Create a success JSON response"
  (json-response `((:success . t)
                   (:data . ,data))))

(defun hash-password (password)
  "Hash a password using SHA256"
  (ironclad:byte-array-to-hex-string
   (ironclad:digest-sequence
    :sha256
    (ironclad:ascii-string-to-byte-array password))))

(defun verify-password (password hash)
  "Verify a password against a hash"
  (string= (hash-password password) hash))

(defun generate-token (user-id)
  "Generate a simple token (for demo purposes)"
  (format nil "~a-~a" 
          user-id
          (ironclad:byte-array-to-hex-string
           (ironclad:digest-sequence
            :sha256
            (ironclad:ascii-string-to-byte-array
             (format nil "~a-~a" user-id (get-universal-time)))))))

(defun current-timestamp ()
  "Get current timestamp as string"
  (multiple-value-bind (sec min hour day month year)
      (decode-universal-time (get-universal-time))
    (format nil "~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d"
            year month day hour min sec)))
