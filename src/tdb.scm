
(define-module (tdb))

(export
  tdb-open
  tdb-context?
  tdb-exists?
  tdb-fetch
  tdb-first-key
  tdb-next-key
  tdb-set!
  tdb-delete!
  with-tdb-transaction
  tdb-cancel-transaction!
  tdb-calculate-hash
  tdb-name
  tdb-last-error
  tdb-assert!
  tdb-close)

(use-modules
  (ice-9 receive)
  (system foreign)
  (rnrs bytevectors)
  (tdb api))

(define free
  (pointer->procedure void (dynamic-func "free" (dynamic-link)) '(*)))

(define-wrapped-pointer-type
  tdb_context*
  tdb-context?
  make-tdb-context
  tdb-context-raw
  (lambda (tdb p)
    (format p "<tdb-context ~x>" (pointer-address (tdb-context-raw tdb)))))

(define (tdb-last-error ctx)
  (pointer->string (tdb_errorstr (tdb-context-raw ctx))))

(define (tdb-assert! ctx val)
  (if val (values) (error (tdb-last-error ctx))))

(define (ok-0 v) (eq? 0 v))

(define (null/errno r errno)
  (if (null-pointer? r)
    (error (strerror errno))
    r))
(define (int/errno r errno)
  (if (eq? 0 r) (values) (error (strerror errno))))

(define (TDB_DATA->bytevector ctx d)
  (let* ([s (parse-c-struct d TDB_DATA)]
         [ptr (car s)]
         [len (cadr s)])
    (if (null-pointer? ptr)
      #f
      (let ([bv (pointer->bytevector ptr len)])
        (free ptr)
        bv))))

(define (bytevector->TDB_DATA b)
  (make-c-struct TDB_DATA
                 (list (bytevector->pointer b)
                       (bytevector-length b))))

(define*
  (tdb-open path
            #:key
            [hash-size 0]
            [clear-if-first #f]
            [lock #t]
            [mmap #t]
            [sync #t]
            [seqnum #f]
            [volatile #f]
            [nesting '()]
            ; [logger #f]
            [create #f]
            [readonly #f]
            [mode #o644])
  (make-tdb-context
    (call-with-values
      (lambda ()
        (tdb_open_ex
          (if path (string->pointer path) %null-pointer)
          hash-size
          (logior
            (if clear-if-first TDB_CLEAR_IF_FIRST 0)
            (if path 0 TDB_INTERNAL)
            (if lock 0 TDB_NOLOCK)
            (if mmap 0 TDB_NOMMAP)
            (if sync 0 TDB_NOSYNC)
            (if seqnum TDB_SEQNUM 0)
            (if volatile TDB_VOLATILE 0)
            (cond
              [(eq? nesting #t) TDB_ALLOW_NESTING]
              [(eq? nesting #f) TDB_DISALLOW_NESTING]
              [#t 0]))
          (logior
            (if create O_CREAT 0)
            (if readonly O_RDONLY O_RDWR))
          mode
          ; Segfaults
          ; (if logger
          ;   (procedure->pointer
          ;     void
          ;     (lambda (tdbctx lvl fmt)
          ;       (logger lvl (pointer->string fmt)))
          ;     (list '* int))
          ;   %null-pointer)
          %null-pointer
          %null-pointer))
      null/errno)))

(define (tdb-close ctx)
  (call-with-values
    (lambda () (tdb_close (tdb-context-raw ctx)))
    int/errno))

(define (tdb-name ctx)
  (pointer->string (tdb_name (tdb-context-raw ctx))))

(define (tdb-calculate-hash d)
  (tdb_jenkins_hash (bytevector->TDB_DATA d)))

(define (tdb-exists? ctx key)
  (eq? 1 (tdb_exists (tdb-context-raw ctx) (bytevector->TDB_DATA key))))

(define (tdb-fetch ctx key)
  (TDB_DATA->bytevector ctx
                        (tdb_fetch (tdb-context-raw ctx)
                                   (bytevector->TDB_DATA key))))

(define (tdb-first-key ctx)
  (TDB_DATA->bytevector ctx
                        (tdb_firstkey (tdb-context-raw ctx))))

(define (tdb-next-key ctx key)
  (TDB_DATA->bytevector ctx
                        (tdb_nextkey (tdb-context-raw ctx)
                                     (bytevector->TDB_DATA key))))

(define*
  (tdb-set! ctx key val
            #:key
            [create '()])
  (ok-0 (tdb_store (tdb-context-raw ctx)
                   (bytevector->TDB_DATA key)
                   (bytevector->TDB_DATA val)
                   (cond
                     [(eq? create #t) TDB_INSERT]
                     [(eq? create #f) TDB_MODIFY]
                     [#t 0]))))

(define (tdb-delete! ctx key)
  (ok-0 (tdb_delete (tdb-context-raw ctx)
                    (bytevector->TDB_DATA key))))

