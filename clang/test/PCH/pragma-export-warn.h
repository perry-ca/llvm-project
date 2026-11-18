// Header for PCH warning test pragma-export-warn.c

#pragma export(sf1(void)) // expected-warning{{missing ')' after '#pragma export' - ignoring}}
#pragma export(s1(int))   // expected-warning{{missing ')' after '#pragma export' - ignoring}}
