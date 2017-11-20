
(define-module (tdb))

(export
  tdb-open
  tdb-context?
  tdb-first-key
  tdb-next-key
  tdb-fetch
  tdb-calculate-hash
  tdb-close)

(use-modules
  (srfi srfi-9)
  (srfi srfi-9 gnu)
  (tdb api))

(define-record-type
  <tdb-context> (make-tdb-context raw)
  tdb-context?
  (raw tdb-context-raw))

(define (error/int ctx r)
  (if (eq? r 0) #t (error (tdb_errorstr ctx))))

(define (assert-not-null! r)
  (if (null-pointer? r)
    (error "Null!")
    r))

(define (error/null ctx r)
  (if (null-pointer? r)
    (error (tdb_errorstr ctx))
    r))

(define*
  (TDB_DATA->bytevector d #:key [error? #f] [free? #f])
  (let* ([s (parse-c-struct d TDB_DATA)]
         [ptr (car s)]
         [len (cadr s)])
    (if (null-pointer? ptr)
      (if error? (error (tdb_errorstr ctx)) #f)
      (let ([bv (pointer->bytevector ptr len)])
        (when free?
          (free ptr))
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
            [create #f]
            [mode 0644])
  (make-tdb-context
    (assert-not-null!
      (tdb_open
        (if path (string->pointer path) "/TDB_INTERNAL")
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
        (if create O_CREAT 0)
        mode))))

(define (tdb-close ctx)
  (error/int ctx (tdb_close (tdb-context-raw ctx))))

(define (tdb-calculate-hash d)
  (tdb_jenkins_hash (bytevector->TDB_DATA d)))

(define (tdb-fetch ctx key)
  (TDB_DATA->bytevector (tdb_fetch (tdb-context-raw ctx)
                                   (bytevector->TDB_DATA key))
                        #:error? #t #:free? #t))

(define (tdb-first-key ctx)
  (TDB_DATA->bytevector (tdb_firstkey (tdb-context-raw ctx))
                        #:error? #t #:free? #t))

(define (tdb-next-key ctx key)
  (TDB_DATA->bytevector (tdb_nextkey (tdb-context-raw ctx)
                                     (bytevector->TDB_DATA key))
                        #:error? #f #:free? #t))

