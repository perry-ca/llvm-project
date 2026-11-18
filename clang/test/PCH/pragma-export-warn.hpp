// Header for PCH warning test pragma-export-warn.cpp

#pragma export(f0(int))                    // expected-warning{{missing ')' after '#pragma export' - ignoring}}
#pragma export(f3(double, double, double)) // expected-warning{{missing ')' after '#pragma export' - ignoring}}
#pragma export(N::sf1(void))               // expected-warning{{missing ')' after '#pragma export' - ignoring}}
#pragma export(N::s1)                      // expected-warning{{missing ')' after '#pragma export' - ignoring}}
