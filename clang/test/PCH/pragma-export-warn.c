// REQUIRES: systemz-registered-target

/// Test this without pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -include %S/pragma-export-warn.h %s -fsyntax-only -verify

/// Test with pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -x c-header -emit-pch -o %t %S/pragma-export-warn.h
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -include-pch %t %s -fsyntax-only -verify

static void static_func(void) {}
static int static_var;
