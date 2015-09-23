#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

static XOP my_xop_is_array;
static OP *my_pp_is_array(pTHX);

static int my_keyword_plugin(pTHX_ char *keyword_ptr, STRLEN keyword_len, OP **op_ptr);

/* For chaining the actual keyword plugin */
int (*next_keyword_plugin)(pTHX_ char *, STRLEN, OP **);


int
my_keyword_plugin(pTHX_ char *keyword_ptr, STRLEN keyword_len, OP **op_ptr) {
  int ret;
  HV *hints;

  /* Enforce lexical scope of this keyword plugin */
  if (!(hints = GvHV(PL_hintgv)))
    return FALSE;
  if (!(hv_fetchs(hints, "Foo", 0)))
    return FALSE;

  if (keyword_len == 8 && memcmp(keyword_ptr, "is_array", 8) == 0)
  {
    /* FIXME emit OP and stuff. See PLua for example. */
    ret = KEYWORD_PLUGIN_STMT;
  }
  else {
    /* Not us. Fall through */
    ret = (*PLU_next_keyword_plugin)(aTHX_ keyword_ptr, keyword_len, op_ptr);
  }

  return ret;
}


OP *
my_pp_is_array(pTHX)
{
  dVAR; dSP;

  /* FIXME add some implementation of is_array here */

  RETURN;
}

MODULE = Foo		PACKAGE = Foo

BOOT:
  /* Setup the actual keyword plugin */
  next_keyword_plugin = PL_keyword_plugin;
  PL_keyword_plugin = my_keyword_plugin;
  /* Set up the custom OP type */
  XopENTRY_set(&my_xop_is_array, xop_name, "is_array");
  XopENTRY_set(&my_xop_is_array, xop_desc, "Custom OP to check whether the given reference points to an array");
  XopENTRY_set(&my_xop_is_array, xop_class, OA_UNOP);
  Perl_custom_op_register(aTHX_ my_pp_is_array, &my_xop_is_array);


