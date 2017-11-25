
# `(tdb)`

Documentation for the `(tdb)` module.

### `tdb-open`

_`tdb-context?`_ `(tdb-open` **`path`** _options..._`)`

Open the TDB database located at **`path`**.

Raises an error if it fails.

- **`path`** - a string, or `#f` to use an internal database.

_options..._ may include:

- _`#:hash-size [integer? 0]`_ passed through to `tdb_open`.
- _`#:create [boolean? #f]`_ if `#t`, create the database file if it does not exist.
- _`#:readonly [boolean? #f]`_ if `#t`, disallow writing to the database.
- _`#:mode [integer? #o644]`_ UNIX file mode to assign to the database file.
- _`#:nesting [boolean?]`_ if specified, allow (`#t`) or disallow (`#f`) transaction nesting.
- _`#:clear-if-first [boolean? #f]`_ passed through to `tdb_open` flags as `TDB_CLEAR_IF_FIRST`.
- _`#:lock [boolean? #t]`_ passed through (negated) to `tdb_open` flags as `TDB_NOLOCK`.
- _`#:mmap [boolean? #t]`_ passed through (negated) to `tdb_open` flags as `TDB_NOMMAP`.
- _`#:sync [boolean? #t]`_ passed through (negated) to `tdb_open` flags as `TDB_NOSYNC`.
- _`#:seqnum [boolean? #f]`_ passed through to `tdb_open` flags as `TDB_SEQNUM`.
- _`#:volatile [boolean? #f]`_ passed through to `tdb_open` flags as `TDB_VOLATILE`.

### `tdb-context?`

_`boolean?`_ `(tdb-context?` **`x`** `)`

Determines whether
**`x`** is an object created with `tdb-open`.

### `tdb-context-readonly?`

_`boolean?`_ `(tdb-context-readonly?` **`db`** `)`

Determines whether
the _`tdb-context?`_ **`db`**
was opened with `#:readonly? #t`.

### `tdb-context-internal?`

_`boolean?`_ `(tdb-context-internal?` **`db`** `)`

Determines whether
the _`tdb-context?`_ **`db`**
is using an internal database.

### `tdb-exists?`

_`boolean?`_ `(tdb-exists?` **`db`** **`key`** `)`

Determines whether
the _`bytevector?`_ **`key`**
exists in
the _`tdb-context?`_ **`db`**.

### `tdb-fetch`, `tdb-ref`

_`bytevector?` or `#f`_ `(tdb-fetch` **`db`** **`key`** `)`

Retrieve the value for
the _`bytevector?`_ **`key`**
in the _`tdb-context?`_ **`db`**,
or `#f` if it does not exist.

`tdb-ref` is an alias for `tdb-fetch`.

### `tdb-first-key`

_`bytevector?` or `#f`_ `(tdb-first-key` **`db`** `)`

Retrieve the "first" key 
in the _`tdb-context?`_ **`db`**,
or `#f` if the database is empty.

### `tdb-next-key`

_`bytevector?` or `#f`_ `(tdb-next-key` **`db`** **`key`** `)`

Retrieve the key "after"
the _`bytevector?`_ **`key`**
in the _`tdb-context?`_ **`db`**,
or `#f` if there is no such key.

Use `tdb-first-key` and `tdb-next-key` together to traverse a database.

### `tdb-set!`

_`boolean?`_ `(tdb-set!` **`db`** **`key`** **`val`** _`[#:create [boolean?]]`_ `)`

Assign
the _`bytevector?`_ **`val`**
as the value for
the _`bytevector?`_ **`key`**
in the _`tdb-context?`_ **`db`**.

If **`val`** is `#f`, this is the same as `tdb-delete!`.
Otherwise, if _`#:create`_ is `#t`, the key must not already exist,
and if it is `#f`, it must already exist.

Returns `#t` on success.
Returns `#f` on error; use `tdb-last-error` to retrieve the error message.

### `tdb-delete!`

_`boolean?`_ `(tdb-delete!` **`db`** **`key`** `)`

Delete
the _`bytevector?`_ **`key`**
from the _`tdb-context?`_ **`db`**.

Returns `#t` on success.
Returns `#f` on error; use `tdb-last-error` to retrieve the error message.

### `tdb-compare-and-set!`

_`#t` or `bytevector?`_ `(tdb-compare-and-set!` **`db`** **`key`** **`current`** **`val`** `)`

Assign
the _`bytevector?`_ **`val`**
as the value for
the _`bytevector?`_ **`key`**
in the _`tdb-context?`_ **`db`**,
but only if the current value for the key is
the _`bytevector?`_ **`current`**.

This operation is performed in a transaction if the context is not internal,
so can be considered atomic when the database is open for multiple writers.

Returns `#t` on success, or the current value for the key if it differs from
the expected current value.

Using `#f` as the value for **`current`** is equivalent to calling `tdb-set!`
with `#:create #t`.

### `with-tdb-transaction`

`(with-tdb-transaction` **`db`** **`function`** `)`

Performs
the _`(lambda (cancel) ...)`_ **`function`**
within an open transaction
in the _`tdb-context?`_ **`db`**.

The function is called with a single parameter, `cancel`, which can be called
to rollback the transaction.
If control reaches the end of the function normally
(i.e. without calling `cancel` or raising an exception),
the transaction is committed.

The return values are either those of the function,
or the parameters passed to `cancel`.

Not valid in a read-only or internal database.

### `tdb-calculate-hash`

_`integer?`_ (tdb-calculate-hash **`datum`** `)`

Calculates the Jenkins hash for
the _`bytevector?`_ **`datum`**.

### `tdb-name`

_`string?`_ `(tdb-name` **`db`** `)`

Returns the name of the _`tdb-context?`_ **`db`**.

### `tdb-last-error`

_`string?`_ `(tdb-last-error` **`db`** `)`

Returns the message text for the most recent error
in the _`tdb-context?`_ **`db`**.

### `tdb-assert!`

_void_ `(tdb-assert!` **`db`** **`val`** `)`

If **`val`** is `#f`, raise an exception with the message from `tdb-last-error`.

### `tdb-close`

_void_ `(tdb-close` **`db`** `)`

Close the _`tdb-context?`_ **`db`**.

Raises an error if it fails.

