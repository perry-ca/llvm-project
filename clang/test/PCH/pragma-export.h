// Header for PCH test pragma-export.c

// None of these symbols is declared in this header; the declarations come from
// the file that includes it.
#pragma export(undecfunc1)
#pragma export(undecfunc2)
#pragma export(undecfunc3)
#pragma export(undecvar1)
#pragma export(undecvar2)

// The symbol is declared after the pragma, in this header.
#pragma export(declfunc)
void declfunc(void);
