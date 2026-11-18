// Header for PCH warning test pragma-export-warn.cpp

#pragma export(unresolved_cpp)    // expected-warning {{failed to resolve '#pragma export' to a declaration}}
#pragma export(non_extern_c_func) // expected-warning {{failed to resolve '#pragma export' to a declaration}}
