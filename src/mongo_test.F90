program mongo_test

  use mongo

  implicit none

  integer db_id, ierr, i
  type(json_file) doc

  call mongo_init()

  db_id = mongo_connect('mongodb://mu02:27117', 'test', 'things')

  call doc%initialize()
  call doc%add('a', 1.0_json_rk)
  call doc%add('b', 1)
  call doc%add('c', 'foo')

  do i = 1, 10
    ierr = mongo_insert(db_id, doc)
  end do
  call mongo_dump_all(db_id)

  call mongo_final()

end program mongo_test
