/*
 * This software is copyright (c) 2009 by Leon Timmermans <leont@cpan.org>.
 *
 * This is free software; you can redistribute it and/or modify it under
 * the same terms as perl itself.
 *
 */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static XS(magic_accessor) {
	dXSARGS;
	
	MAGIC* magic = mg_find((SV*)cv, PERL_MAGIC_ext);
	SV* self = ST(0);
	if (items == 2) {
		HE* ref = hv_fetch_ent((HV*)SvRV(self), magic->mg_obj, 1, magic->mg_len);
		SvSetSV(HeVAL(ref), ST(1));
		ST(0) = HeVAL(ref);
	}
	else if (items == 1) {
		HE* ref = hv_fetch_ent((HV*)SvRV(self), magic->mg_obj, 0, magic->mg_len);
		ST(0) = HeVAL(ref);
	}
	else {
		Perl_croak(aTHX_ "Accessor '%s' needs 0 or 1 arguments", SvPV_nolen(magic->mg_obj));
	}
	XSRETURN(1);
}

static HE* get_key(pTHX_ SV* name) {
	HV* cache = *(HV**)hv_fetch(PL_modglobal, "Accessors::Magic", 16, 0);
	HE* key = hv_fetch_ent(cache, name, TRUE, 0);
	if (!SvOK(HeVAL(key)))
		SvSetSV(HeVAL(key), name);
	return key;
}

MODULE = Accessors::Magic				PACKAGE = Accessors::Magic

PROTOTYPES: DISABLED

BOOT:
	hv_store(PL_modglobal, "Accessors::Magic", 16, (SV*)newHV(), 0);

void
_add_accessor(package, name)
	SV* package;
	SV* name;
	CODE:
		SV* subname = sv_2mortal(newSVpvf("%s::%s", SvPV_nolen(package), SvPV_nolen(name)));
		CV* sub = newXS(SvPV_nolen(subname), magic_accessor, __FILE__);
		HE* key = get_key(aTHX_ name);
		sv_magicext((SV*)sub, HeVAL(key), PERL_MAGIC_ext, NULL, NULL, HeHASH(key));
