// RUN: %clang_cc1 -x c++ -triple s390x-ibm-zos -fsyntax-only -verify %s

#pragma map(f // expected-warning {{missing ')' after '#pragma map' - ignoring}}
#pragma map(f( // expected-warning {{missing ')' after '#pragma map' - ignoring}}
#pragma map(f(T // expected-warning {{missing ')' after '#pragma map' - ignoring}}
#pragma map(f(T, "def") // expected-warning {{missing ')' after '#pragma map' - ignoring}}
#pragma map(f(int), "abc")
extern "C" void f(double, double) {
}
