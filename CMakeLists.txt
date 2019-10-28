cmake_minimum_required(VERSION 3.6)

project(fortran-mongo C Fortran)

include(FindPkgConfig)

pkg_check_modules(MONGOC REQUIRED libmongoc-1.0)

include_directories(${MONGOC_INCLUDE_DIRS})
link_directories(${MONGOC_LIBRARY_DIRS})

set(sources
  src/const.h
  src/mongoc_smuggler.c
  src/mongo_mod.F90
)

add_library(fortran_mongo ${sources})
target_link_libraries(fortran_mongo ${MONGOC_LIBRARIES})
