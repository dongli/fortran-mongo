#include "const.h"

module mongo_mod

  use iso_c_binding
  use json_module

  implicit none

  private

  public mongo_init
  public mongo_connect
  public mongo_dump_all
  public mongo_insert
  public mongo_final
  public mongo_error

  integer, public, parameter :: mongo_noerr = FORTRAN_MONGO_NO_ERROR

  interface
    subroutine mongoc_smuggler_init() bind(c, name='mongoc_smuggler_init')
    end subroutine mongoc_smuggler_init

    integer(c_int) function mongoc_smuggler_connect(uri, db_name, col_name, cid) result(ierr) bind(c, name='mongoc_smuggler_connect')
      use iso_c_binding
      character(c_char), intent(in) :: uri(*)
      character(c_char), intent(in) :: db_name(*)
      character(c_char), intent(in) :: col_name(*)
      integer(c_int), intent(out) :: cid
    end function mongoc_smuggler_connect

    integer(c_int) function mongoc_smuggler_dump_all(cid) result(ierr) bind(c, name='mongoc_smuggler_dump_all')
      use iso_c_binding
      integer(c_int) cid
    end function mongoc_smuggler_dump_all

    integer(c_int) function mongoc_smuggler_insert_json(cid, json_str) result(ierr) bind(c, name='mongoc_smuggler_insert_json')
      use iso_c_binding
      integer(c_int) cid
      character(c_char) json_str(*)
    end function mongoc_smuggler_insert_json

    subroutine mongoc_smuggler_final() bind(c, name='mongoc_smuggler_final')
    end subroutine mongoc_smuggler_final
  end interface 

contains

  subroutine mongo_init()

    call mongoc_smuggler_init()

  end subroutine mongo_init

  integer function mongo_connect(uri, db_name, col_name, cid) result(ierr)

    character(*), intent(in) :: uri
    character(*), intent(in) :: db_name
    character(*), intent(in) :: col_name
    integer, intent(out) :: cid

    ierr = mongoc_smuggler_connect(c_str(uri), c_str(db_name), c_str(col_name), cid)

  end function mongo_connect

  subroutine mongo_dump_all(cid)

    integer, intent(in) :: cid

    integer ierr

    ierr = mongoc_smuggler_dump_all(cid)

  end subroutine mongo_dump_all

  integer function mongo_insert(cid, doc) result(ierr)

    integer, intent(in) :: cid
    type(json_file), intent(inout) :: doc

    character(kind=json_ck,len=:), allocatable, target :: str
    character, allocatable :: tmp(:)
    integer i

    call doc%print_to_string(str)

    allocate(tmp(len_trim(str)+1))
    do i = 1, len_trim(str)
      tmp(i:i) = str(i:i)
    end do
    tmp(i:i) = c_null_char

    ierr = mongoc_smuggler_insert_json(cid, tmp)

    deallocate(tmp)

  end function mongo_insert

  subroutine mongo_final()

    call mongoc_smuggler_final()

  end subroutine mongo_final

  function mongo_error(ierr)

    integer, intent(in) :: ierr
    character(:), allocatable :: mongo_error

    select case (ierr)
    case (FORTRAN_MONGO_MEMORY_ERROR)
      mongo_error = 'Exceeds connection limit!'
    case (FORTRAN_MONGO_URI_NEW_ERROR)
      mongo_error = 'Invalid URI argument!'
    case (FORTRAN_MONGO_CLIENT_NEW_ERROR)
      mongo_error = 'Failed to new client!'
    case (FORTRAN_MONGO_BAD_DB_ID)
      mongo_error = 'Bad database ID!'
    case (FORTRAN_MONGO_BAD_CURSOR)
      mongo_error = 'Bad cursor!'
    case (FORTRAN_MONGO_NO_ERROR)
      mongo_error = ''
    end select

  end function mongo_error

  function c_str(f_str)

    character(*), intent(in) :: f_str
    character(len=len_trim(f_str)+1,kind=c_char) c_str

    c_str = trim(f_str) // c_null_char

  end function c_str

end module mongo_mod
