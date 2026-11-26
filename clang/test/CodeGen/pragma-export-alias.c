// REQUIRES: systemz-registered-target
// RUN: %clang_cc1 %s -emit-llvm -fzos-extensions -triple s390x-none-zos -fvisibility=hidden -o - | FileCheck %s

// A function or variable declared with the alias attribute is a definition, so
// the pragma is only applied when it precedes the declaration of the alias. The
// alias attribute names the aliasee by its symbol name; #pragma export does not
// change the name.

// Exported aliasee; the alias itself is not exported.
#pragma export(t1)
void t1(void) {}
void a1(void) __attribute__((alias("t1")));

// Exported alias, pragma before the alias declaration.
void t2(void) {}
#pragma export(a2)
void a2(void) __attribute__((alias("t2")));

// Exported aliasee and exported alias.
#pragma export(t3)
void t3(void) {}
#pragma export(a3)
void a3(void) __attribute__((alias("t3")));

// Variables: exported aliasee, the alias is not exported.
#pragma export(v4)
int v4 = 4;
extern int va4 __attribute__((alias("v4")));

// Variables: exported alias, pragma before the alias declaration.
int v5 = 5;
#pragma export(va5)
extern int va5 __attribute__((alias("v5")));

// CHECK-DAG: @v4 = global i32 4
// CHECK-DAG: @v5 = hidden global i32 5
// CHECK-DAG: @va4 = hidden alias i32, ptr @v4
// CHECK-DAG: @va5 = alias i32, ptr @v5
// CHECK-DAG: @a1 = hidden alias void (), ptr @t1
// CHECK-DAG: @a2 = alias void (), ptr @t2
// CHECK-DAG: @a3 = alias void (), ptr @t3
// CHECK-DAG: define void @t1()
// CHECK-DAG: define hidden void @t2()
// CHECK-DAG: define void @t3()
