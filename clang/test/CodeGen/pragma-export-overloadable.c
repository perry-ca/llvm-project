// REQUIRES: systemz-registered-target
// RUN: %clang_cc1 %s -emit-llvm -fzos-extensions -triple s390x-none-zos -fvisibility=hidden -o - | FileCheck %s

// Overloadable functions are mangled, so #pragma export only applies to the
// overload that lacks __attribute__((overloadable)).

// Pragma before the declarations, overloadable function first. The pragma must
// not be applied to the overloadable declaration (ProcessPragmaExport); it is
// applied when the unmarked overload is declared.
#pragma export(a)
__attribute__((overloadable)) void a(double) {}
void a(int) {}

// Pragma before the declarations, unmarked function first.
#pragma export(b)
void b(int) {}
__attribute__((overloadable)) void b(double) {}

// Pragma between the declarations, unmarked function first.
void c(int);
#pragma export(c)
__attribute__((overloadable)) void c(double) {}
void c(int) {}

// Pragma between the declarations, overloadable function first.
__attribute__((overloadable)) void d(double) {}
#pragma export(d)
void d(int) {}

// Pragma after the declarations, which are not yet definitions.
void e(int);
__attribute__((overloadable)) void e(double);
#pragma export(e)
void e(int) {}
__attribute__((overloadable)) void e(double) {}

__attribute__((overloadable)) void f(double);
void f(int);
#pragma export(f)
__attribute__((overloadable)) void f(double) {}
void f(int) {}

// CHECK-DAG: define hidden void @_Z1ad(
// CHECK-DAG: define void @a(
// CHECK-DAG: define void @b(
// CHECK-DAG: define hidden void @_Z1bd(
// CHECK-DAG: define void @c(
// CHECK-DAG: define hidden void @_Z1cd(
// CHECK-DAG: define hidden void @_Z1dd(
// CHECK-DAG: define void @d(
// CHECK-DAG: define void @e(
// CHECK-DAG: define hidden void @_Z1ed(
// CHECK-DAG: define hidden void @_Z1fd(
// CHECK-DAG: define void @f(
