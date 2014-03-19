#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

/* Defines macros and does an extern declaration for the fptrs */
#include "module_withcapi.h"

/* The actual definition of the fptr storage */
DEFINE_SYMBOLS_Module_WithCAPI

MODULE = Foo		PACKAGE = Foo		

BOOT:
  /* Goes and looks up symbols, assigning to our fptrs. */
  INIT_SYMBOLS_Module_WithCAPI;

int
xs_my_sum(int a, int b)
  CODE:
    RETVAL = my_sum_ptr(a, b);
  OUTPUT: RETVAL

int
xs_my_diff(int a, int b)
  CODE:
    RETVAL = my_diff_ptr(a, b);
  OUTPUT: RETVAL
