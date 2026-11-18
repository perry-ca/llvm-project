// Header for PCH warning test pragma-export-warn.c

#pragma export(unresolved_func) // expected-warning {{failed to resolve '#pragma export' to a declaration}}
#pragma export(unresolved_var)  // expected-warning {{failed to resolve '#pragma export' to a declaration}}
#pragma export(static_func)     // expected-warning {{#pragma export is applicable to symbols with external linkage only; not applied to 'static_func'}}
#pragma export(static_var)      // expected-warning {{#pragma export is applicable to symbols with external linkage only; not applied to 'static_var'}}
