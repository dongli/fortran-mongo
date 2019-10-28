module mongo_mod

  use iso_c_binding

  implicit none

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

  subroutine mongo_final()

    call mongoc_smuggler_final()

  end subroutine mongo_final

end module mongo_mod
