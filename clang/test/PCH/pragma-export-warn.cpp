// REQUIRES: systemz-registered-target

// Test this without pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -x c++ -include %S/pragma-export-warn.hpp -fsyntax-only -verify %s

// Test with pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -x c++-header -emit-pch -o %t %S/pragma-export-warn.hpp
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -x c++ -include-pch %t -DPCH -fsyntax-only -verify %s

#ifdef PCH
// expected-no-diagnostics
#endif
