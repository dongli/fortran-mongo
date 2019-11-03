#include <bson/bson.h>
#include "const.h"

int num_object = 0;
bson_t *objects[100];

int bson_smuggler_create() {
  objects[num_object] = bson_new();
  return num_object++;
}


