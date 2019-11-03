program mongo_test

  use mongo

  implicit none

  integer db_id, ierr
  type(hash_table_type) doc
  type(hash_table_type) bar

  call mongo_init()

  db_id = mongo_connect('mongodb://localhost:27017', 'test_db', 'test_col')

  doc = hash_table(chunk_size=10)
  call doc%insert('a', 1)
  call doc%insert('b', 'foo')
  call doc%insert('c', 1.5)
  bar = hash_table(chunk_size=10)
  call bar%insert('d', .true.)
  call doc%insert('bar', bar)

  ierr = mongo_insert(db_id, doc)

  call mongo_final()

end program mongo_test
