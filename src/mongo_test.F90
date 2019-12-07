program mongo_test

  use mongo

  implicit none

  integer cid, ierr, i
  type(json_file) doc

  call mongo_init()

  ierr = mongo_connect('mongodb://mu02:27117', 'test', 'things', cid)
  if (ierr /= mongo_noerr) then
    write(*, *) mongo_error(ierr)
    stop 1
  end if

  call doc%initialize()
  call doc%add('a', 1.0_json_rk)
  call doc%add('b', 1)
  call doc%add('c', 'foo')

  do i = 1, 10
    ierr = mongo_insert(cid, doc)
    if (ierr /= mongo_noerr) then
      write(*, *) 'Failed to insert!'
      stop 1
    end if
  end do
  call mongo_dump_all(cid)

  call mongo_final()

end program mongo_test
