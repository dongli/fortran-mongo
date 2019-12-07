#include <mongoc.h>
#include <bson.h>
#include "const.h"

struct MongoObjectBundle {
  mongoc_client_t *client;
  mongoc_database_t *database;
  mongoc_collection_t * collection;
};

size_t num_bundle = 0;
struct MongoObjectBundle bundles[100];

struct MongoObjectBundle* get_bundle(const int cid) {
  if (cid >= num_bundle) {
    return NULL;
  }
  return &bundles[cid];
}

void mongoc_smuggler_init() {
  /*
   * Initialize libmongoc's internals.
   */
  mongoc_init();
}

int mongoc_smuggler_connect(const char *uri_str, const char *db_name, const char *col_name, int *cid) {
  mongoc_uri_t *uri;
  bson_error_t error;
  struct MongoObjectBundle *bundle;

  if (num_bundle == 100) return FORTRAN_MONGO_MEMORY_ERROR;
  bundle = &bundles[num_bundle];

  /*
   * Check if URI argument is valid.
   */
  uri = mongoc_uri_new_with_error(uri_str, &error);
  if (!uri) return FORTRAN_MONGO_URI_NEW_ERROR;

  /*
   * Create a new client instance.
   */
  bundle->client = mongoc_client_new_from_uri(uri);
  if (!bundle->client) return FORTRAN_MONGO_CLIENT_NEW_ERROR;

  /*
   * Get database and collection handles.
   */
  bundle->database = mongoc_client_get_database(bundle->client, db_name);
  bundle->collection = mongoc_client_get_collection(bundle->client, db_name, col_name);

  /*
   * Destroy unused variables.
   */
  mongoc_uri_destroy(uri);

  /*
   * Return database ID as bundle number.
   */
  *cid = (int) num_bundle++;

  return FORTRAN_MONGO_NO_ERROR;
}

int mongoc_smuggler_dump_all(const int *cid) {
  struct MongoObjectBundle *bundle;
  mongoc_cursor_t *cursor;
  const bson_t *doc;
  bson_t *query;
  char *str;

  bundle = get_bundle(*cid);
  if (!bundle) return FORTRAN_MONGO_BAD_DB_ID;

  query = bson_new();
  if (!query) return FORTRAN_MONGO_BAD_QUERY;
  cursor = mongoc_collection_find_with_opts(bundle->collection, query, NULL, NULL);
  if (!cursor) return FORTRAN_MONGO_BAD_CURSOR;
  while (mongoc_cursor_next(cursor, &doc)) {
    str = bson_as_canonical_extended_json(doc, NULL);
    printf("%s\n", str);
    bson_free(str);
  }
  bson_destroy(query);
  mongoc_cursor_destroy(cursor);
}

int mongoc_smuggler_insert_json(const int *cid, const uint8_t *json_str) {
  struct MongoObjectBundle *bundle;

  bundle = get_bundle(*cid);
  if (!bundle) return FORTRAN_MONGO_BAD_DB_ID;

  bson_t *bson;
  bson_error_t error;
  bson = bson_new_from_json(json_str, -1, &error);
  if (!bson) {
    return FORTRAN_MONGO_BSON_NEW_ERROR;
  }

  mongoc_bulk_operation_t *bulk;

  bulk = mongoc_collection_create_bulk_operation_with_opts(bundle->collection, NULL);

  mongoc_bulk_operation_insert(bulk, bson);

  if (!mongoc_bulk_operation_execute(bulk, NULL, &error)) return FORTRAN_MONGO_INSERT_ERROR;

  bson_destroy(bson);
  mongoc_bulk_operation_destroy(bulk);

  return FORTRAN_MONGO_NO_ERROR;
}

void mongoc_smuggler_final() {
  for (int i = 0; i < num_bundle; i++) {
    mongoc_collection_destroy(bundles[i].collection);
    mongoc_database_destroy(bundles[i].database);
    mongoc_client_destroy(bundles[i].client);
  }
  mongoc_cleanup();
}

