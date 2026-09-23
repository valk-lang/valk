// Structs passed and returned by value, checked from tests/library/c-abi.valk
#include <stdbool.h>

typedef struct { float x, y; } V2;
typedef struct { float x, y, z; } V3;
typedef struct { float x, y, z, w; } V4;
typedef struct { unsigned char r, g, b, a; } Col;
typedef struct { V3 pos; V3 target; V3 up; float fovy; int proj; } Cam;
typedef struct { unsigned int id; int w, h, mips, fmt; } Tex;
typedef struct { double a; float b; } DF;
typedef struct { double a, b; } D2;
typedef struct { int a; float b; } IF;
typedef struct { short a, b, c; } S3;
typedef struct { unsigned char a, b, c; } B3;
typedef struct { float v; } F1;
typedef struct { float v[3]; } FA;
typedef struct { char name[20]; int id; } Named;
typedef struct { float m[16]; } Mat;
typedef struct { void *p; int n; } PI;

float v2_sum(V2 v) { return v.x + v.y * 10; }
V2 v2_make(float a) { V2 v = { a, -a }; return v; }
float v3_sum(V3 v) { return v.x + v.y * 10 + v.z * 100; }
V3 v3_make(float a) { V3 v = { a, a * 2, a * 3 }; return v; }
float v4_sum(V4 v) { return v.x + v.y * 10 + v.z * 100 + v.w * 1000; }
V4 v4_make(float a) { V4 v = { a, a + 1, a + 2, a + 3 }; return v; }
int col_sum(Col c) { return c.r + c.g * 2 + c.b * 3 + c.a * 4; }
Col col_make(int a) { Col c = { a, a + 1, a + 2, a + 3 }; return c; }
float cam_sum(Cam c, int k) { return c.pos.x + c.target.y + c.up.z + c.fovy + c.proj + k; }
Cam cam_make(float f) { Cam c = { { f, 0, 0 }, { 0, f * 2, 0 }, { 0, 0, f * 3 }, 45, 1 }; return c; }
int tex_sum(Tex t, V2 p, Col c) { return t.id + t.w + t.h + t.mips + t.fmt + (int)p.x + (int)p.y + c.a; }
Tex tex_make(int i) { Tex t = { i, i + 1, i + 2, i + 3, i + 4 }; return t; }
double df_sum(DF v) { return v.a + v.b * 10; }
DF df_make(double a) { DF v = { a, (float)(a * 2) }; return v; }
double d2_sum(D2 v) { return v.a + v.b * 10; }
D2 d2_make(double a) { D2 v = { a, a * 3 }; return v; }
float if_sum(IF v) { return v.a + v.b * 10; }
IF if_make(int a) { IF v = { a, a * 0.5f }; return v; }
int s3_sum(S3 v) { return v.a + v.b * 10 + v.c * 100; }
S3 s3_make(short a) { S3 v = { a, -a, a * 2 }; return v; }
int b3_sum(B3 v) { return v.a + v.b * 10 + v.c * 100; }
B3 b3_make(int a) { B3 v = { a, a + 1, a + 2 }; return v; }
float f1_sum(F1 v, float k) { return v.v + k; }
F1 f1_make(float a) { F1 v = { a * 4 }; return v; }
float fa_sum(FA v) { return v.v[0] + v.v[1] * 10 + v.v[2] * 100; }
FA fa_make(float a) { FA v = { { a, a + 1, a + 2 } }; return v; }
int named_sum(Named v) { int s = v.id; for (int i = 0; i < 20 && v.name[i]; i++) s += v.name[i]; return s; }
Named named_make(int id) { Named v = { "valk", id }; return v; }
float mat_sum(Mat m) { float s = 0; for (int i = 0; i < 16; i++) s += m.m[i] * (i + 1); return s; }
Mat mat_make(float a) { Mat m; for (int i = 0; i < 16; i++) m.m[i] = a + i; return m; }
long long pi_sum(PI v) { return (long long)(v.p != 0) + v.n; }
PI pi_make(int n) { PI v = { (void *)&pi_make, n }; return v; }
bool b_not(bool b) { return !b; }
int small(unsigned char a, signed char b, unsigned short c, short d) { return a + b + c + d; }
// SysV: the fifth V3 no longer fits the vector registers
float v3_many(V3 a, V3 b, V3 c, V3 d, V3 e) { return v3_sum(a) + v3_sum(b) + v3_sum(c) + v3_sum(d) + v3_sum(e) * 2; }
// SysV: the result pointer and five integers leave one register, PI needs two
Tex ints_then_pair(long long a, long long b, long long c, long long d, long long e, PI p) {
    Tex t = { (unsigned int)(a + b + c + d + e), p.n, p.p != 0, 0, 7 };
    return t;
}
// SysV: eight doubles take every vector register, V2 goes on the stack
double doubles_then_v2(double a, double b, double c, double d, double e, double f, double g, double h, V2 v) {
    return a + b + c + d + e + f + g + h + v2_sum(v);
}

// The same conventions in the other direction: exports of c-abi.valk
V3 valk_v3_make(float a);
float valk_v3_sum(V3 v);
Col valk_col_make(unsigned char a);
int valk_col_sum(Col c);
Cam valk_cam_make(float f);
float valk_cam_sum(Cam c, int k);
S3 valk_s3_make(short a);
int valk_s3_sum(S3 v);
DF valk_df_make(double a);
double valk_df_sum(DF v);
float valk_v3_many(V3 a, V3 b, V3 c, V3 d, V3 e);
Tex valk_ints_then_pair(long long a, long long b, long long c, long long d, long long e, PI p);

int check_exports(void) {
    int bad = 0;
    V3 v = valk_v3_make(2);
    if (v.x != 2 || v.y != 4 || v.z != 6) bad |= 1;
    if (valk_v3_sum(v) != 642) bad |= 2;
    Col c = valk_col_make(200);
    if (c.r != 200 || c.g != 201 || c.b != 202 || c.a != 203) bad |= 4;
    if (valk_col_sum(c) != 200 + 201 * 2 + 202 * 3 + 203 * 4) bad |= 8;
    Cam cam = valk_cam_make(5);
    if (cam.pos.x != 5 || cam.target.y != 10 || cam.up.z != 15 || cam.fovy != 45 || cam.proj != 1) bad |= 16;
    if (valk_cam_sum(cam, 7) != 83) bad |= 32;
    S3 s = valk_s3_make(-9);
    if (s.a != -9 || s.b != 9 || s.c != -18) bad |= 64;
    if (valk_s3_sum(s) != -9 + 90 - 1800) bad |= 128;
    DF d = valk_df_make(3);
    if (d.a != 3 || d.b != 6) bad |= 256;
    if (valk_df_sum(d) != 63) bad |= 512;
    V3 x = { 1, 0, 0 }, y = { 0, 1, 0 }, z = { 0, 0, 1 }, w = { 2, 0, 0 }, u = { 0, 0, 3 };
    if (valk_v3_many(x, y, z, w, u) != 713) bad |= 1024;
    PI p = { (void *)&check_exports, 42 };
    Tex t = valk_ints_then_pair(1, 2, 3, 4, 5, p);
    if (t.id != 15 || t.w != 42 || t.h != 1 || t.fmt != 7) bad |= 2048;
    return bad;
}
