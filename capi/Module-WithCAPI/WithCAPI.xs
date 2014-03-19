#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "module_withcapi.h"

int
my_sum(int a, int b)
{
  return a + b;
}

int
my_diff(int a, int b)
{
  return a - b;
}

int
my_prod(int a, int b)
{
  return a * b;
}

MODULE = Module::WithCAPI		PACKAGE = Module::WithCAPI		

