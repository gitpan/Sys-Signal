#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

typedef struct {
    Sighandler_t h;
    int signo;
    SV *savesv;
    char *name;
    I32 len;
} sys_signal_t;

typedef sys_signal_t * Sys__Signal;

static void my_sighandler(int i)
{
    SV *sv = perl_get_sv("Sys::Signal::Test", FALSE);
    fprintf(stderr, "ok %d (my_sighandler)\n", (int)SvIV(sv));
}

MODULE = Sys::Signal		PACKAGE = Sys::Signal		

BOOT:
if (perl_get_sv("Sys::Signal::Test", FALSE)) {
    Perl_rsignal(SIGALRM, my_sighandler);
}

Sys::Signal
set(classname, signame, cv)
    SV *classname
    SV *signame
    SV *cv

    PREINIT:
    I32 signo;
    STRLEN len;
    char *name;
    SV **elm;

    CODE:
    name = SvPV(signame,len);
    RETVAL = (sys_signal_t *)safemalloc(sizeof(*RETVAL));
    RETVAL->signo = Perl_whichsig(name);
    RETVAL->h =  Perl_rsignal_state(RETVAL->signo);
    RETVAL->name = strdup(name);
    RETVAL->len = len;

    if (!PL_siggv) {
	(void)Perl_gv_fetchpv("SIG", TRUE, SVt_PVHV);
    }
    elm = Perl_hv_fetch(GvHV(PL_siggv), name, len, TRUE);
    RETVAL->savesv = Perl_newSVsv(*elm);
    Perl_sv_setsv(*elm, cv);
    Perl_mg_set(*elm);

    OUTPUT:
    RETVAL

void
DESTROY(s)
    Sys::Signal s

    PREINIT:
    SV **elm;

    CODE:
    elm = Perl_hv_fetch(GvHV(PL_siggv), s->name, s->len, TRUE);
    Perl_sv_setsv(*elm, s->savesv);
    Perl_mg_set(*elm);

    Perl_rsignal(s->signo, s->h);
    safefree(s->name);
    safefree(s);
