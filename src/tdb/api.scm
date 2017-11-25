
(define-module (tdb api))

(export
  TDB_REPLACE
  TDB_INSERT
  TDB_MODIFY

  TDB_DEFAULT

  TDB_CLEAR_IF_FIRST
  TDB_INTERNAL
  TDB_NOLOCK
  TDB_NOMMAP
  TDB_CONVERT
  TDB_BIGENDIAN
  TDB_NOSYNC
  TDB_SEQNUM
  TDB_VOLATILE
  TDB_ALLOW_NESTING
  TDB_DISALLOW_NESTING
  TDB_INCOMPATIBLE_HASH

  TDB_DATA

  tdb_open
  tdb_open_ex
  tdb_set_max_dead
  tdb_reopen
  tdb_reopen_all
  tdb_error
  tdb_errorstr
  tdb_fetch
  tdb_delete
  tdb_store
  tdb_append
  tdb_close
  tdb_firstkey
  tdb_nextkey
  tdb_exists
  tdb_lockall
  tdb_lockall_nonblock
  tdb_unlockall
  tdb_lockall_read
  tdb_lockall_read_nonblock
  tdb_unlockall_read
  tdb_lockall_mark
  tdb_lockall_unmark
  tdb_name
  tdb_fd
  tdb_get_logging_private
  tdb_set_logging_function
  tdb_transaction_start
  tdb_transaction_start_nonblock
  tdb_transaction_prepare_commit
  tdb_transaction_commit
  tdb_transaction_cancel
  tdb_get_seqnum
  tdb_hash_size
  tdb_map_size
  tdb_get_flags
  tdb_add_flags
  tdb_remove_flags
  tdb_enable_seqnum
  tdb_increment_seqnum_nonblock
  tdb_jenkins_hash)

(use-modules
  (system foreign)
  (rnrs bytevectors))

(define TDB_REPLACE 1)
(define TDB_INSERT 2)
(define TDB_MODIFY 3)

(define TDB_DEFAULT 0)

(define TDB_CLEAR_IF_FIRST 1)
(define TDB_INTERNAL 2)
(define TDB_NOLOCK   4)
(define TDB_NOMMAP   8)
(define TDB_CONVERT 16)
(define TDB_BIGENDIAN 32)
(define TDB_NOSYNC   64)
(define TDB_SEQNUM   128)
(define TDB_VOLATILE   256)
(define TDB_ALLOW_NESTING 512)
(define TDB_DISALLOW_NESTING 1024)
(define TDB_INCOMPATIBLE_HASH 2048)

(define *lib* (dynamic-link "libtdb"))

(define (tdb-foreign ret name . args)
  (pointer->procedure ret (dynamic-func name *lib*) args))
(define (tdb-foreign/errno ret name . args)
  (pointer->procedure ret (dynamic-func name *lib*) args #:return-errno? #t))

(define TDB_ERROR int)
(define TDB_DATA (list '* int))
(define TDB_DATA* '*)
(define tdb_context* '*)
(define char* '*)
(define flags int)
(define tdb_log_function '*)

(define tdb_open
  (tdb-foreign/errno tdb_context* "tdb_open"
                     char* int flags int int))

(define tdb_open_ex
  (tdb-foreign/errno tdb_context* "tdb_open_ex"
                     char* int flags int int tdb_log_function '*))

(define tdb_set_max_dead
  (tdb-foreign void "tdb_set_max_dead"
               tdb_context* int))

(define tdb_reopen
  (tdb-foreign int "tdb_reopen"
               tdb_context*))

(define tdb_reopen_all
  (tdb-foreign int "tdb_reopen_all"
               int))

(define tdb_set_logging_function
  (tdb-foreign void "tdb_set_logging_function"
               tdb_context* tdb_log_function))
; void tdb_set_logging_function(struct tdb_context *tdb, const struct tdb_logging_context *log_ctx);

(define tdb_error
  (tdb-foreign TDB_ERROR "tdb_error"
               tdb_context*))

(define tdb_errorstr
  (tdb-foreign char* "tdb_errorstr"
               tdb_context*))

(define tdb_fetch
  (tdb-foreign TDB_DATA "tdb_fetch"
               tdb_context* TDB_DATA))

; int tdb_parse_record(struct tdb_context *tdb, TDB_DATA key,
;                               int (*parser)(TDB_DATA key, TDB_DATA data,
;                                             void *private_data),
;                               void *private_data);

(define tdb_delete
  (tdb-foreign int "tdb_delete"
               tdb_context* TDB_DATA))

(define tdb_store
  (tdb-foreign int "tdb_store"
               tdb_context* TDB_DATA TDB_DATA int))

(define tdb_append
  (tdb-foreign int "tdb_append"
               tdb_context* TDB_DATA TDB_DATA))

(define tdb_close
  (tdb-foreign/errno int "tdb_close"
                     tdb_context*))

(define tdb_firstkey
  (tdb-foreign TDB_DATA "tdb_firstkey"
               tdb_context*))

(define tdb_nextkey
  (tdb-foreign TDB_DATA "tdb_nextkey"
               tdb_context* TDB_DATA))

; int tdb_traverse(struct tdb_context *tdb, tdb_traverse_func fn, void *private_data);

; int tdb_traverse_read(struct tdb_context *tdb, tdb_traverse_func fn, void *private_data);

(define tdb_exists
  (tdb-foreign int "tdb_exists"
               tdb_context* TDB_DATA))

(define tdb_lockall
  (tdb-foreign int "tdb_lockall"
               tdb_context*))

(define tdb_lockall_nonblock
  (tdb-foreign int "tdb_lockall_nonblock"
               tdb_context*))

(define tdb_unlockall
  (tdb-foreign int "tdb_unlockall"
               tdb_context*))

(define tdb_lockall_read
  (tdb-foreign int "tdb_lockall_read"
               tdb_context*))

(define tdb_lockall_read_nonblock
  (tdb-foreign int "tdb_lockall_read_nonblock"
               tdb_context*))

(define tdb_unlockall_read
  (tdb-foreign int "tdb_unlockall_read"
               tdb_context*))

(define tdb_lockall_mark
  (tdb-foreign int "tdb_lockall_mark"
               tdb_context*))

(define tdb_lockall_unmark
  (tdb-foreign int "tdb_lockall_unmark"
               tdb_context*))

(define tdb_name
  (tdb-foreign char* "tdb_name"
               tdb_context*))

(define tdb_fd
  (tdb-foreign int "tdb_fd"
               tdb_context*))

; tdb_log_func tdb_log_fn(struct tdb_context *tdb);

(define tdb_get_logging_private
  (tdb-foreign '* "tdb_get_logging_private"
               tdb_context*))

(define tdb_transaction_start
  (tdb-foreign int "tdb_transaction_start"
               tdb_context*))

(define tdb_transaction_start_nonblock
  (tdb-foreign int "tdb_transaction_start_nonblock"
               tdb_context*))

(define tdb_transaction_prepare_commit
  (tdb-foreign int "tdb_transaction_prepare_commit"
               tdb_context*))

(define tdb_transaction_commit
  (tdb-foreign int "tdb_transaction_commit"
               tdb_context*))

(define tdb_transaction_cancel
  (tdb-foreign int "tdb_transaction_cancel"
               tdb_context*))

(define tdb_get_seqnum
  (tdb-foreign int "tdb_get_seqnum"
               tdb_context*))

(define tdb_hash_size
  (tdb-foreign int "tdb_hash_size"
               tdb_context*))

(define tdb_map_size
  (tdb-foreign size_t "tdb_map_size"
               tdb_context*))

(define tdb_get_flags
  (tdb-foreign flags "tdb_get_flags"
               tdb_context*))

(define tdb_add_flags
  (tdb-foreign void "tdb_add_flags"
               tdb_context* flags))

(define tdb_remove_flags
  (tdb-foreign void "tdb_remove_flags"
               tdb_context* flags))

(define tdb_enable_seqnum
  (tdb-foreign void "tdb_enable_seqnum"
               tdb_context*))

(define tdb_increment_seqnum_nonblock
  (tdb-foreign void "tdb_increment_seqnum_nonblock"
               tdb_context*))

(define tdb_jenkins_hash
  (tdb-foreign int "tdb_jenkins_hash"
               TDB_DATA*))

; int tdb_check(struct tdb_context *tdb,
;               int (*check) (TDB_DATA key, TDB_DATA data, void *private_data),
;               void *private_data);

