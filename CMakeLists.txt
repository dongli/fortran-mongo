cmake_minimum_required(VERSION 3.6)

project(fortran-mongo C Fortran)

if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-underscoring")
endif ()

include(FindPkgConfig)

pkg_check_modules(MONGOC REQUIRED libmongoc-1.0)

include_directories(${MONGOC_INCLUDE_DIRS})
link_directories(${MONGOC_LIBRARY_DIRS})

add_subdirectory(lib/container)

set(sources
  src/const.h
  src/bson_smuggler.c
  src/mongoc_smuggler.c
  src/mongo_mod.F90
  src/mongo.F90
)

add_library(fortran_mongo ${sources})
target_link_libraries(fortran_mongo ${MONGOC_LIBRARIES} fortran_container)

add_executable(mongo_test.exe src/mongo_test.F90)
target_link_libraries(mongo_test.exe fortran_mongo)
