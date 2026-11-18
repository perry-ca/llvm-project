// REQUIRES: systemz-registered-target

// Test this without pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -include %S/pragma-export-warn.h -fsyntax-only -verify %s

// Test with pch.
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -x c-header -emit-pch -o %t %S/pragma-export-warn.h
// RUN: %clang_cc1 -triple s390x-none-zos -fzos-extensions -include-pch %t -DPCH -fsyntax-only -verify %s

#ifdef PCH
// expected-no-diagnostics
#endif
