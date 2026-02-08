
#if OS == win
link "libssl"
link "libcrypto"
link "advapi32"
link "user32"
link "bcrypt"
link "crypt32"
#elif OS == macos
link "ssl"
link "crypto"
#else
link "ssl"
link "crypto"
#end

#if OS == linux
link dynamic "dl"
link ":libc_nonshared.a"
#end

pointer SSL {}
pointer SSL_CTX {}

enum ERROR {
    NONE                 (0)
    SSL                  (1)
    WANT_READ            (2)
    WANT_WRITE           (3)
    WANT_X509_LOOKUP     (4)
    SYSCALL              (5) // look at error stack/return value/errno
    ZERO_RETURN          (6)
    WANT_CONNECT         (7)
    WANT_ACCEPT          (8)
    WANT_ASYNC           (9)
    WANT_ASYNC_JOB       (10)
    WANT_CLIENT_HELLO_CB (11)
    WANT_RETRY_VERIFY    (12)
}

value SSL_VERIFY_PEER (0x1)

value SSL3_VERSION (0x0300)
value TLS1_VERSION (0x0301)
value TLS1_1_VERSION (0x0302)
value TLS1_2_VERSION (0x0303)
value TLS1_3_VERSION (0x0304)
value DTLS1_VERSION (0xFEFF)
value DTLS1_2_VERSION (0xFEFD)
value DTLS1_BAD_VER (0x0100)

value SSL_OP_NO_ANTI_REPLAY (1 << 24)
value SSL_OP_NO_SSLv3 (1 << 25)
value SSL_OP_NO_TLSv1 (1 << 26)
value SSL_OP_NO_TLSv1_2 (1 << 27)
value SSL_OP_NO_TLSv1_1 (1 << 28)
value SSL_OP_NO_TLSv1_3 (1 << 29)
value SSL_OP_NO_DTLSv1 (1 << 26)
value SSL_OP_NO_DTLSv1_2 (1 << 27)

value SSL_CTRL_SET_MIN_PROTO_VERSION (123)
value SSL_CTRL_SET_MAX_PROTO_VERSION (124)

value SSL_CTRL_SET_TLSEXT_HOSTNAME (55)
value TLSEXT_NAMETYPE_host_name (0)

fn SSL_CTX_new(method: ptr) SSL_CTX;
fn SSL_CTX_free(ctx: SSL_CTX) void;

fn SSL_new(ctx: SSL_CTX) SSL;
fn SSL_set_fd(ssl: SSL, fd: i32) void;
fn SSL_free(ctx: SSL_CTX) void;
fn SSL_connect(ctx: SSL_CTX) i32;

fn SSL_get_fd(ctx: SSL) i32;
fn SSL_get_version(ssl: SSL) cstring;
fn SSL_write(ssl: SSL, data: ptr, bytes: uint) i32;
fn SSL_read(ssl: SSL, data: ptr, bytes: uint) i32;
fn SSL_write_ex(ssl: SSL, data: ptr, bytes: uint, bytes_written_uint_ptr: ptr) i32;
fn SSL_read_ex(ssl: SSL, data: ptr, bytes: uint, bytes_read_uint_ptr: ptr) i32;
fn SSL_set1_host(ssl: SSL, host: cstring) i32;
fn SSL_set_verify(ssl: SSL, mode: i32, cb: ?fnptr(i32, ptr)(i32)) i32;
fn SSL_set_cipher_list(ssl: SSL, ciphers: cstring) i32;
fn SSL_ctrl(ssl: SSL, cmd: i32, larg: int, parg: ?ptr) int;

fn SSL_get_error(ssl: SSL, ret: i32) i32;
fn ERR_clear_error();
fn ERR_get_error() uint;
fn ERR_error_string(error: uint, buffer: ?ptr) cstring;

fn TLS_client_method() ptr;
fn SSLv23_client_method() ptr;

fn SSL_CTX_set_verify(ssl: SSL, mode: i32, cb: ?fnptr(i32, ptr)(i32)) i32;
fn SSL_CTX_set_options(ctx: SSL_CTX, flags: int);
fn SSL_CTX_ctrl(ctx: SSL_CTX, cmd: i32, larg: int, parg: ?ptr) int;
fn SSL_CTX_load_verify_locations(ctx: SSL_CTX, ca_file: cstring, ca_path: ?cstring) i32;
fn SSL_CTX_set_default_verify_paths(ctx: SSL_CTX) i32;

fn X509_get_default_cert_file() cstring;
