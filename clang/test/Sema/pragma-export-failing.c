// REQUIRES: systemz-registered-target
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions %s -fsyntax-only -verify

#pragma export(d0)                         // expected-warning{{failed to resolve '#pragma export' to a declaration}}
#pragma export(f9)                         // expected-warning{{failed to resolve '#pragma export' to a declaration}}

#pragma export(sf1) // expected-warning{{'#pragma export' is applicable to symbols with external linkage only; not applied to 'sf1'}}
#pragma export(s1) // expected-warning{{'#pragma export' is applicable to symbols with external linkage only; not applied to 's1'}}
static void sf1(void) {}
static int s1;

static void sf0(void) {}
int v0;
static int s0;
#pragma export(sf0) // expected-warning{{'#pragma export' is applicable to symbols with external linkage only; not applied to 'sf0'}}
#pragma export(s0) // expected-warning{{'#pragma export' is applicable to symbols with external linkage only; not applied to 's0'}}

#pragma export(f1) // expected-error {{visibility does not match previous declaration}}
int f1() __attribute__((visibility("hidden")));
int f2() __attribute__((visibility("hidden")));
#pragma export(f2) // expected-error {{visibility does not match previous declaration}}


int hoo() __attribute__((visibility("hidden")));

int foo() { return 4; }
#pragma export(foo)  // expected-warning {{'#pragma export' can only applied before a symbol is defined}}

int var = 4;
#pragma export(var) // expected-warning {{'#pragma export' can only applied before a symbol is defined}}

int func() {
#pragma export(local) // expected-error{{'#pragma export' can only appear at file scope}}
  int local;
  int l2;
#pragma export(l2) // expected-error{{'#pragma export' can only appear at file scope}}
  return local+l2;
}

int local = 2;
int l2 =4;

// Testing __attribute__((overloadable)). Overloadable functions are mangled, so
// the pragma can only apply to the single overload that lacks the attribute.
// Cases that are accepted are covered in CodeGen/pragma-export-overloadable.c.

// All overloads are marked, so there is nothing to export.
void ov1(int) __attribute__((overloadable));
void ov1(double) __attribute__((overloadable));
#pragma export(ov1) // expected-warning{{failed to resolve '#pragma export' to a declaration}}

#pragma export(ov2) // expected-warning{{failed to resolve '#pragma export' to a declaration}}
void ov2(int) __attribute__((overloadable));
void ov2(double) __attribute__((overloadable));

// The unmarked overload is defined.
__attribute__((overloadable)) void ov3(double) {}
void ov3(int) {}
#pragma export(ov3) // expected-warning {{'#pragma export' can only applied before a symbol is defined}}

// Testing __attribute__((alias)). A declaration with the alias attribute is a
// definition. Cases that are accepted are covered in
// CodeGen/pragma-export-alias.c.
void at1(void) {}
void al1(void) __attribute__((alias("at1")));
#pragma export(al1) // expected-warning {{'#pragma export' can only applied before a symbol is defined}}

int av1 = 1;
extern int ava1 __attribute__((alias("av1")));
#pragma export(ava1) // expected-warning {{'#pragma export' can only applied before a symbol is defined}}

