// REQUIRES: systemz-registered-target

/// Test this without pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -x c++ -include %S/pragma-export-warn.hpp %s -fsyntax-only -verify

/// Test with pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -x c++-header -emit-pch -o %t %S/pragma-export-warn.hpp
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -x c++ -include-pch %t %s -fsyntax-only -verify

// In C++, non-extern "C" functions do not resolve #pragma export.
void non_extern_c_func(int) {}

// expected-warning@pragma-export-warn.hpp:3 {{failed to resolve '#pragma export' to a declaration}}
// expected-warning@pragma-export-warn.hpp:4 {{failed to resolve '#pragma export' to a declaration}}
