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
    subroutine mongoc_smuggler_init()
    end subroutine mongoc_smuggler_init

    integer(c_int) function mongoc_smuggler_connect(uri, db_name, col_name) result(id)
      use iso_c_binding
      character(c_char) uri(*)
      character(c_char) db_name
      character(c_char) col_name
    end function mongoc_smuggler_connect

    subroutine mongoc_smuggler_final()
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

  integer function mongo_insert(db_id, doc) result(ierr)

    integer, intent(in) :: db_id
    type(hash_table_type), intent(in) :: doc



  end function mongo_insert

  subroutine mongo_final()

    call mongoc_smuggler_final()

  end subroutine mongo_final

end module mongo_mod
