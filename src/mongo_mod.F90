module mongo_mod

  use iso_c_binding

  implicit none

  private

  public mongo_init
  public mongo_connect
  public mongo_dump_all
  public mongo_insert
  public mongo_final

  interface
    subroutine mongoc_smuggler_init() bind(c, name='mongoc_smuggler_init')
    end subroutine mongoc_smuggler_init

    integer(c_int) function mongoc_smuggler_connect(uri, db_name, col_name) result(id) bind(c, name='mongoc_smuggler_connect')
      use iso_c_binding
      character(c_char) uri(*)
      character(c_char) db_name(*)
      character(c_char) col_name(*)
    end function mongoc_smuggler_connect

    integer(c_int) function mongoc_smuggler_dump_all(db_id) result(ierr) bind(c, name='mongoc_smuggler_dump_all')
      use iso_c_binding
      integer(c_int) db_id
    end function mongoc_smuggler_dump_all

    integer(c_int) function mongoc_smuggler_insert_int(db_id, key, val) result(ierr) bind(c, name='mongoc_smuggler_insert_int')
      use iso_c_binding
      integer(c_int) db_id
      character(c_char) key(*)
      integer(c_int) val
    end function mongoc_smuggler_insert_int

    integer(c_int) function mongoc_smuggler_insert_float(db_id, key, val) result(ierr) bind(c, name='mongoc_smuggler_insert_float')
      use iso_c_binding
      integer(c_int) db_id
      character(c_char) key(*)
      real(c_float) val
    end function mongoc_smuggler_insert_float

    integer(c_int) function mongoc_smuggler_insert_double(db_id, key, val) result(ierr) bind(c, name='mongoc_smuggler_insert_double')
      use iso_c_binding
      integer(c_int) db_id
      character(c_char) key(*)
      real(c_double) val
    end function mongoc_smuggler_insert_double

    integer(c_int) function mongoc_smuggler_insert_str(db_id, key, val) result(ierr) bind(c, name='mongoc_smuggler_insert_str')
      use iso_c_binding
      integer(c_int) db_id
      character(c_char) key(*)
      character(c_char) val(*)
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

    id = mongoc_smuggler_connect(to_c_str(uri), to_c_str(db_name), to_c_str(col_name))

  end function mongo_connect

  subroutine mongo_dump_all(db_id)

    integer, intent(in) :: db_id

    integer ierr

    ierr = mongoc_smuggler_dump_all(db_id)

  end subroutine mongo_dump_all

  recursive integer function mongo_insert(db_id) result(ierr)

    integer, intent(in) :: db_id

  end function mongo_insert

  subroutine mongo_final()

    call mongoc_smuggler_final()

  end subroutine mongo_final

  function to_c_str(f_str) result(c_str)

    character(*), intent(in) :: f_str
    character(len=len_trim(f_str)+1,kind=c_char) c_str

    c_str = trim(f_str) // c_null_char

  end function to_c_str

end module mongo_mod
