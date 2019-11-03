module mongo_mod

  use iso_c_binding
  use hash_table_mod

  implicit none

  private

  public mongo_init
  public mongo_connect
  public mongo_insert
  public mongo_final

  interface
    subroutine mongoc_smuggler_init() bind(c, name='mongoc_smuggler_init')
    end subroutine mongoc_smuggler_init

    integer(c_int) function mongoc_smuggler_connect(uri, db_name, col_name) result(id) bind(c, name='mongoc_smuggler_connect')
      use iso_c_binding
      character(c_char) uri(*)
      character(c_char) db_name
      character(c_char) col_name
    end function mongoc_smuggler_connect

    integer(c_int) function mongoc_smuggler_insert_int(db_id, key, val) result(ierr) bind(c, name='mongoc_smuggler_insert_int')
      use iso_c_binding
      integer(c_int) db_id
      character(c_char) key
      integer(c_int) val
    end function mongoc_smuggler_insert_int

    integer(c_int) function mongoc_smuggler_insert_float(db_id, key, val) result(ierr) bind(c, name='mongoc_smuggler_insert_float')
      use iso_c_binding
      integer(c_int) db_id
      character(c_char) key
      real(c_float) val
    end function mongoc_smuggler_insert_float

    integer(c_int) function mongoc_smuggler_insert_double(db_id, key, val) result(ierr) bind(c, name='mongoc_smuggler_insert_double')
      use iso_c_binding
      integer(c_int) db_id
      character(c_char) key
      real(c_double) val
    end function mongoc_smuggler_insert_double

    integer(c_int) function mongoc_smuggler_insert_str(db_id, key, val) result(ierr) bind(c, name='mongoc_smuggler_insert_str')
      use iso_c_binding
      integer(c_int) db_id
      character(c_char) key
      character(c_char) val
    end function mongoc_smuggler_insert_str

    subroutine mongoc_smuggler_final() bind(c, name='mongoc_smuggler_final')
    end subroutine mongoc_smuggler_final
  end interface 

contains

  subroutine mongo_init()

    call mongoc_smuggler_init()

  end subroutine mongo_init

  integer function mongo_connect(uri, db_name, col_name) result(id)

    character(*), intent(in) :: uri
    character(*), intent(in) :: db_name
    character(*), intent(in) :: col_name

    id = mongoc_smuggler_connect(uri, db_name, col_name)

  end function mongo_connect

  recursive integer function mongo_insert(db_id, doc) result(ierr)

    integer, intent(in) :: db_id
    type(hash_table_type), intent(in) :: doc

    type(hash_table_iterator_type) iterator

    iterator = hash_table_iterator(doc)
    do while (.not. iterator%ended())
      select type (val => iterator%value)
      type is (integer)
        print *, val
        ierr = mongoc_smuggler_insert_int(db_id, trim(iterator%key), val)
      type is (real(4))
        print *, val
        ierr = mongoc_smuggler_insert_float(db_id, trim(iterator%key), val)
      type is (real(8))
        print *, val
        ierr = mongoc_smuggler_insert_double(db_id, trim(iterator%key), val)
      type is (character(*))
        print *, val
        ierr = mongoc_smuggler_insert_str(db_id, trim(iterator%key), val)
      end select
      call iterator%next()
    end do

  end function mongo_insert

  subroutine mongo_final()

    call mongoc_smuggler_final()

  end subroutine mongo_final

end module mongo_mod
