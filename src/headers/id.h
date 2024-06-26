
#ifndef _H_ID
#define _H_ID

#include "typedefs.h"

Idf* idf_make(Allocator* alc, int type, void* item);
Decl* decl_make(Allocator* alc, Func* func, char* name, Type* type, bool is_arg);
char* gen_export_name(Nsc* nsc, char* suffix);
Id* read_id(Parser* p, char* first_part, Id* buf);
Idf* idf_by_id(Parser* p, Scope* scope, Id* id, bool must_exist);
Idf* scope_find_idf(Scope* scope, char* name, bool recursive);
//
Idf* get_valk_idf(Build* b, char* ns, char* name, bool must_exist);
Func *get_valk_func(Build *b, char *namespace, char *name);
Func *get_valk_class_func(Build *b, char *namespace, char *class_name, char* fn);
Class *get_valk_class(Build *b, char *namespace, char *name);
Global *get_valk_global(Build *b, char *namespace, char *name);
ValueAlias *get_valk_value_alias(Build *b, char *namespace, char *name);
Snippet *get_valk_snippet(Build *b, char *namespace, char *name);

#endif