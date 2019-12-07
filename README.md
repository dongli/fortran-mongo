# Introduction

fortran-mongo is a MongoDB binding library for Fortran. It is based on two external libraries:

- mongo-c-driver: Provide low-level MongoDB API;
- json-fortran: Provide Fortran JSON types.

# Examples

## Insert data

```Fortran
use mongo

integer cid, ierr
type(json_file) doc

call mongo_init()

ierr = mongo_connect('mongodb://<host>:<port>', '<database>', '<collection>', cid)
if (ierr /= mongo_noerr) then
  write(*, *) mongo_error(ierr)
  stop 1
end if

call doc%initialize()
call doc%add('a', 1.0_json_rk)
call doc%add('b', 1)
call doc%add('c', 'foo')

ierr = mongo_insert(cid, doc)
if (ierr /= mongo_noerr) then
  write(*, *) 'Failed to insert!'
  stop 1
end if

call mongo_dump_all(cid)

call mongo_final()
```

# Contributors

- Li Dong
- Xiaobo Tian
