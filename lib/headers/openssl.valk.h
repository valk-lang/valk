
#if OS == win
link static "libssl";
link static "libcrypto";
link static "advapi32";
link static "user32";
link static "bcrypt";
link static "crypt32";
#elif OS == macos
link static "ssl";
link static "crypto";
#else
link static "ssl";
link static "crypto";
#end

#if OS == linux
link dynamic "dl";
link dynamic ":libc_nonshared.a";
#end

pointer SSL {}
pointer SSL_CTX {}

fn SSL_CTX_new(method: ptr) SSL_CTX;
fn SSL_new(ctx: SSL_CTX) SSL;
fn SSL_set_fd(ssl: SSL, fd: i32) void;
fn SSL_free(ctx: SSL_CTX) void;
fn SSL_connect(ctx: SSL_CTX) i32;

fn SSL_write(ssl: SSL, data: ptr, bytes: uint) i32;
fn SSL_read(ssl: SSL, data: ptr, bytes: uint) i32;
fn SSL_write_ex(ssl: SSL, data: ptr, bytes: uint, bytes_written_uint_ptr: ptr) i32;
fn SSL_read_ex(ssl: SSL, data: ptr, bytes: uint, bytes_read_uint_ptr: ptr) i32;

fn SSL_get_error(ssl: SSL, ret: i32) i32;

fn TLS_client_method() ptr;
fn SSLv23_client_method() ptr;
