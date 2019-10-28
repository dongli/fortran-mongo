#include <mongoc.h>
#include "const.h"

struct MongoObjectBundle {
  mongoc_client_t *client;
  mongoc_database_t *database;
  mongoc_collection_t * collection;
};

size_t num_bundle = 0;
struct MongoObjectBundle bundles[100];

void mongoc_smuggler_init() {
  /*
   * Initialize libmongoc's internals.
   */
  mongoc_init();
}

int mongoc_smuggler_connect(const char *uri_str, const char *db_name, const char *col_name) {
  mongoc_uri_t *uri;
  bson_error_t error;
  struct MongoObjectBundle *bundle;

  if (num_bundle == 100) {
    return FORTRAN_MONGO_MEMORY_ERROR;
  }
  bundle = &bundles[num_bundle];

  uri = mongoc_uri_new_with_error(uri_str, &error);
  if (!uri) {
    return FORTRAN_MONGO_URI_ERROR;
  }

  /*
   * Create a new client instance.
   */
  bundle->client = mongoc_client_new_from_uri(uri);
  if (!bundle->client) {
    return FORTRAN_MONGO_INTERNAL_ERROR;
  }

  bundle->database = mongoc_client_get_database(bundle->client, db_name);
  bundle->collection = mongoc_client_get_collection(bundle->client, db_name, col_name);

  return num_bundle++;
}

void mongoc_smuggler_final() {
  mongoc_cleanup();
}
