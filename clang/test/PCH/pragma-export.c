// REQUIRES: systemz-registered-target

/// Test this without pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -include %S/pragma-export.h %s -emit-llvm -o - | FileCheck %s

/// Test with pch.
// RUN: %clang_cc1 -source-date-epoch 1613676318 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -x c-header -emit-pch -o %t %S/pragma-export.h
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -include-pch %t %s -emit-llvm -o - | FileCheck %s

/// Compile it a few times to check that the PCH file is deterministic.
// RUN: %clang_cc1 -source-date-epoch 1613676318 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -x c-header -emit-pch -o %t.cmp %S/pragma-export.h
// RUN: diff %t %t.cmp >/dev/null
// RUN: %clang_cc1 -source-date-epoch 1613676318 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -x c-header -emit-pch -o %t.cmp %S/pragma-export.h
// RUN: diff %t %t.cmp >/dev/null
// RUN: %clang_cc1 -source-date-epoch 1613676318 -triple s390x-none-zos -fzos-extensions -fvisibility=hidden -x c-header -emit-pch -o %t.cmp %S/pragma-export.h
// RUN: diff %t %t.cmp >/dev/null

/// Check that #pragma export is exported into PCHs even if the header contains
/// no declaration of the symbol. With -fvisibility=hidden, an exported symbol
/// has default visibility and the others are hidden.
void undecfunc1(void) {}
void undecfunc2(void);
void undecfunc3(void) {}
int undecvar1;
int undecvar2 = 2;

void notexported(void) {}
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
// CHECK-DAG: define hidden void @notexported()
// CHECK-DAG: declare void @undecfunc2()
// CHECK-DAG: declare void @declfunc()
