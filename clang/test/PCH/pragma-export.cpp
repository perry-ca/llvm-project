// REQUIRES: systemz-registered-target

/// Test this without pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -include %S/pragma-export.hpp -x c++ %s -emit-llvm -o - | FileCheck %s

/// Test with pch.
// RUN: %clang_cc1 -source-date-epoch 1613676318 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -x c++-header -emit-pch -o %t %S/pragma-export.hpp
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -include-pch %t -x c++ %s -emit-llvm -o - | FileCheck %s

/// Compile it a few times to check that the PCH file is deterministic.
// RUN: %clang_cc1 -source-date-epoch 1613676318 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -x c++-header -emit-pch -o %t.cmp %S/pragma-export.hpp
// RUN: diff %t %t.cmp >/dev/null
// RUN: %clang_cc1 -source-date-epoch 1613676318 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -x c++-header -emit-pch -o %t.cmp %S/pragma-export.hpp
// RUN: diff %t %t.cmp >/dev/null
// RUN: %clang_cc1 -source-date-epoch 1613676318 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -x c++-header -emit-pch -o %t.cmp %S/pragma-export.hpp
// RUN: diff %t %t.cmp >/dev/null

/// Check that #pragma export is exported into PCHs even if the header contains
/// no declaration of the symbol in C++. In C++, functions require extern "C"
/// to be exported with pragma export.
extern "C" void undecfunc1(void) {}
extern "C" void undecfunc2(void);
extern "C" void undecfunc3(void) {}

// Overloaded functions: only the extern "C" one is exported.
void undecoverload(double, double) {}
extern "C" void undecoverload(int) {}
void undecoverload(int, int) {}

int undecvar1;
int undecvar2 = 2;

extern "C" void notexported(void) {}
int notexportedvar;

void use(void) {
  undecfunc2();
  declfunc();
}

// CHECK-DAG: @undecvar1 = global i32
// CHECK-DAG: @undecvar2 = global i32
// CHECK-DAG: @notexportedvar = hidden global i32
// CHECK-DAG: define void @undecfunc1()
// CHECK-DAG: define void @undecfunc3()
// CHECK-DAG: define hidden void @_Z13undecoverloaddd(double noundef %0, double noundef %1)
// CHECK-DAG: define void @undecoverload(i32 noundef signext %0)
// CHECK-DAG: define hidden void @_Z13undecoverloadii(i32 noundef signext %0, i32 noundef signext %1)
// CHECK-DAG: define hidden void @notexported()
// CHECK-DAG: declare void @undecfunc2()
// CHECK-DAG: declare void @declfunc()
