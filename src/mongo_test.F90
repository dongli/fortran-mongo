program mongo_test

  use mongo

  implicit none

  integer db_id

  call mongo_init()

  db_id = mongo_connect('mongodb://mu02:27117', 'test', 'things')
  call mongo_dump_all(db_id)

  call mongo_final()

end program mongo_test
