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
    return MONGO_FORTRAN_MEMORY_ERROR;
  }
  bundle = &bundles[num_bundle];

  uri = mongoc_uri_new_with_error(uri_str, &error);
  if (!uri) {
    return MONGO_FORTRAN_URI_ERROR;
  }

  /*
   * Create a new client instance.
   */
  bundle->client = mongoc_client_new_from_uri(uri);
  if (!bundle->client) {
    return MONGO_FORTRAN_INTERNAL_ERROR;
  }

  bundle->database = mongoc_client_get_database(bundle->client, db_name);
  bundle->collection = mongoc_client_get_collection(bundle->client, db_name, col_name);

  mongoc_uri_destroy(uri);

  return num_bundle++;
}

int mongoc_smuggler_dump_all(const int *db_id) {
  struct MongoObjectBundle *bundle;
  mongoc_cursor_t *cursor;
  const bson_t *doc;
  bson_t *query;
  char *str;

  bundle = &bundles[*db_id];
  if (!bundle) {
    printf("bundle is wrong!\n");
    exit(1);
  }

  query = bson_new();
  if (!query) {
    printf("query is wrong!\n");
    exit(1);
  }
  cursor = mongoc_collection_find_with_opts(bundle->collection, query, NULL, NULL);
  if (!cursor) {
    printf("cursor is wrong!\n");
    exit(1);
  }
  while (mongoc_cursor_next(cursor, &doc)) {
    str = bson_as_canonical_extended_json(doc, NULL);
    printf("%s\n", str);
    bson_free(str);
  }
  bson_destroy(query);
  mongoc_cursor_destroy(cursor);
}

int mongoc_smuggler_insert_json(const int *db_id, const uint8_t *json_str) {
  struct MongoObjectBundle *bundle;

  bundle = &bundles[*db_id];
  if (!bundle) {
    printf("bundle is wrong!\n");
    exit(1);
  }

  bson_t *bson;
  bson_error_t error;
  bson = bson_new_from_json(json_str, -1, &error);
  if (!bson) {
    printf("Failed to convert JSON to BSON!\n");
    exit(1);
  }

  mongoc_bulk_operation_t *bulk;

  bulk = mongoc_collection_create_bulk_operation_with_opts(bundle->collection, NULL);

  mongoc_bulk_operation_insert(bulk, bson);

  if (!mongoc_bulk_operation_execute(bulk, NULL, &error)) {
    printf("Failed to insert BSON! %s\n", error.message);
    exit(1);
  }

  bson_destroy(bson);
  mongoc_bulk_operation_destroy(bulk);

  return MONGO_FORTRAN_NO_ERROR;
}

void mongoc_smuggler_final() {
  for (int i = 0; i < num_bundle; i++) {
    mongoc_collection_destroy(bundles[i].collection);
    mongoc_database_destroy(bundles[i].database);
    mongoc_client_destroy(bundles[i].client);
  }
  mongoc_cleanup();
}
