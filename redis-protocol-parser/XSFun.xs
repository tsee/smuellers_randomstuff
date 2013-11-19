#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#ifdef NOINLINE
#   define STATIC_INLINE STATIC
#elif defined(_MSC_VER)
#   define STATIC_INLINE STATIC __inline
#else
#   define STATIC_INLINE STATIC inline
#endif

typedef struct {
  unsigned char *start;
  unsigned char *pos;
  unsigned char *end; /* points to AFTER string */
  STRLEN len;
} rds_parser_t;

#define RDS_ASSERT_STRLEN(parser, len) STMT_START { \
    if (parser->end - parser->pos < len) \
      croak("Early end of string: Need %i characters, but have only %i left", \
            (int)len, (int)(parser->end - parser->pos)); \
  } STMT_END

#define RDS_ASSERT_STRLEN_MSG(parser, len, msg) STMT_START { \
    if (parser->end - parser->pos < len) \
      croak("Early end of string: Need %i characters, but have only %i left %s", \
            (int)len, (int)(parser->end - parser->pos), msg); \
  } STMT_END


STATIC_INLINE void
rds_init_parser(rds_parser_t *parser, unsigned char *str, STRLEN length)
{
  parser->start = str;
  parser->pos = str;
  parser->len = length;
  parser->end = (unsigned char *)(str + (size_t)length);
}


STATIC_INLINE unsigned int
rds_parse_int(rds_parser_t *parser)
{
  unsigned char *str = parser->pos;
  unsigned char *end_ptr = parser->end;
  int num = 0;
  int sign = 1;
  if (str != end_ptr && *str == '-') {
    sign = -1;
    ++str;
  }
  while (*str != '\r' && str != end_ptr) {
    num = (num*10)+(*str - '0');
    ++str;
  }
  parser->pos = str;
  return num * sign;
}

STATIC_INLINE int
rds_parse_len(rds_parser_t *parser)
{
  int len;
  RDS_ASSERT_STRLEN(parser, 2);
  (parser->pos)++;
  len = rds_parse_int(parser);
  RDS_ASSERT_STRLEN(parser, 2);
  parser->pos += 2;
  return len;
}


STATIC_INLINE SV *
rds_parse_elem(pTHX_ rds_parser_t *parser)
{
  SV *retval;
  RDS_ASSERT_STRLEN(parser, 2);
  switch (*parser->pos) {
  case ':':
    (parser->pos)++;
    retval = newSViv(rds_parse_int(parser));
    RDS_ASSERT_STRLEN(parser, 2);
    parser->pos += 2;
    break;
  case '$': {
      const int len = rds_parse_len(parser);
      if (len == -1) {
        retval = &PL_sv_undef;
      }
      else {
        RDS_ASSERT_STRLEN(parser, len+2);
        retval = newSVpvn(parser->pos, len);
        parser->pos += len + 2;
      }
    }
    break;
  default:
    croak("Invalid Redis response at character %i", (int)(parser->pos - parser->start));
  }
  return retval;
}


MODULE = XSFun PACKAGE = XSFun

## usage: redis_concat(qw(LPUSH mylistkey foo));

void
redis_encode(...)
  PREINIT:
    SV *retval;
    int i;
    char *str;
  PPCODE:
    retval = sv_2mortal(newSVpvf("*%lu\r\n", (unsigned long)items));

    for (i = 0; i < items; ++i) {
      /* FIXME UTF8 */
      sv_catpvf(retval, "$%lu\r\n", (unsigned long)SvCUR(ST(i)));
      sv_catsv(retval, ST(i));
    }

    PUSHs(retval);
    XSRETURN(1);

void
redis_parse(response)
    SV *response;
  PREINIT:
    SV *retval;
    AV *av;
    unsigned char *str;
    STRLEN len;
    int i;
    rds_parser_t parser;
  PPCODE:
    /* FIXME UTF8? */
    str = SvPV(response, len);
    if (!len)
      croak("Invalid Redis response: empty string or not a string");

    switch (str[0]) {
    case '*': {
        /* Multi-bulk reply */
        rds_init_parser(&parser, str, len);

        const int nargs = rds_parse_len(&parser);
        if (nargs == -1) {
          PUSHs(&PL_sv_undef);
          XSRETURN(1);
        }

        av = newAV();
        retval = sv_2mortal(newRV_noinc((SV *)av));

        for (i = 0; i < nargs; ++i) {
          av_push(av, rds_parse_elem(aTHX_ &parser));
        }
      }
      break;
    case '$':
      /* Bulk reply */
      rds_init_parser(&parser, str, len);

      av = newAV();
      retval = sv_2mortal(newRV_noinc((SV *)av));
      av_push(av, rds_parse_elem(aTHX_ &parser));
      break;
    case ':':
      /* Integer reply */
      rds_init_parser(&parser, str, len);
      (parser.pos)++;
      retval = sv_2mortal(newSViv(rds_parse_int(&parser)));
      break;
    case '+':
      /* Status reply */
      retval = sv_2mortal(newSVpvn(str+1, len-1));
      break;
    case '-':
      /* Error reply */
      retval = sv_2mortal(newSVpvn(str, len)); /* include leading - in error reply */
      break;
    default:
      croak("Invalid Redis response: starts with invalid character");
    }
    PUSHs(retval);
    XSRETURN(1);

