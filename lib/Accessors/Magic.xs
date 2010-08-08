/*
 * This software is copyright (c) 2009, 2010 by Leon Timmermans <leont@cpan.org>.
 *
 * This is free software; you can redistribute it and/or modify it under
 * the same terms as perl itself.
 *
 */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef XSPROTO
#define XSPROTO(foo) XS(foo)
#endif

static MAGIC* S_get_magic(pTHX_ CV* cv) {
	MAGIC* magic = mg_find((SV*)cv, PERL_MAGIC_ext);
	if (!magic)
		Perl_croak(aTHX_ "Accessor isn't magical, something very weird is going on");
	return magic;
}
#define get_magic(cv) S_get_magic(aTHX_ cv)

static HV* S_checked_self(pTHX_ SV* self, MAGIC* magic) {
	HV* ret;
	if (!SvROK(self) || SvTYPE(ret = (HV*)SvRV(self)) != SVt_PVHV)
		Perl_croak(aTHX_ "Can't call accessor on non-hashref", SvPV_nolen((SV*)magic->mg_obj));
	return ret;
}
#define checked_self(self, magic) S_checked_self(aTHX_ self, magic)

static XS(magic_accessor) {
	dXSARGS;
	
	MAGIC* magic = get_magic(cv);
	if (items == 1) {
		HV* self = checked_self(ST(0), magic);
		HE* ref = hv_fetch_ent(self, magic->mg_obj, FALSE, magic->mg_len);
		ST(0) = ref ? HeVAL(ref) : &PL_sv_undef;
	}
	else if (items == 2) {
		HV* self = checked_self(ST(0), magic);
		HE* ref = hv_fetch_ent(self, magic->mg_obj, TRUE, magic->mg_len);
		SvSetSV(HeVAL(ref), ST(1));
		ST(0) = HeVAL(ref);
	}
	else {
		Perl_croak(aTHX_ "Read-write accessor '%s' can't take %d arguments", SvPV_nolen(magic->mg_obj), items - 1);
	}
	XSRETURN(1);
}

static XS(magic_reader) {
	dXSARGS;
	
	MAGIC* magic = get_magic(cv);
	if (items == 1) {
		HV* self = checked_self(ST(0), magic);
		HE* ref = hv_fetch_ent(self, magic->mg_obj, FALSE, magic->mg_len);
		ST(0) = ref ? HeVAL(ref) : &PL_sv_undef;
	}
	else if(items == 2)
		Perl_croak(aTHX_ "Can't assign to '%s'", SvPV_nolen(magic->mg_obj));
	else 
		Perl_croak(aTHX_ "Read accessor '%s' can't take %d arguments", SvPV_nolen(magic->mg_obj), items - 1);
	XSRETURN(1);
}

static XS(magic_writer) {
	dXSARGS;
	
	MAGIC* magic = get_magic(cv);
	if (items == 2) {
		HV* self = checked_self(ST(0), magic);
		HE* ref = hv_fetch_ent(self, magic->mg_obj, TRUE, magic->mg_len);
		SvSetSV(HeVAL(ref), ST(1));
		ST(0) = HeVAL(ref);
	}
	else if (items == 1)
		Perl_croak(aTHX_ "Write accessor '%s' want an argument", SvPV_nolen((SV*)magic->mg_obj));
	else
		Perl_croak(aTHX_ "Write accessor '%s' can't take %d arguments", SvPV_nolen(magic->mg_obj), items - 1);
	XSRETURN(1);
}

static HE* get_key(pTHX_ SV* name) {
	HV* cache = *(HV**)hv_fetch(PL_modglobal, "Accessors::Magic", 16, FALSE);
	HE* key = hv_fetch_ent(cache, name, TRUE, 0);
	if (!SvOK(HeVAL(key)))
		SvSetSV(HeVAL(key), name);
	return key;
}

static void add_accessor(pTHX_ SV* package, SV* name, SV* rename, XSPROTO(func)) {
	SV* subname = sv_2mortal(newSVpvf("%s::%s", SvPV_nolen(package), SvPV_nolen(rename)));
	CV* sub = newXS(SvPV_nolen(subname), func, __FILE__);
	HE* key = get_key(aTHX_ name);
	MAGIC* magic = sv_magicext((SV*)sub, HeVAL(key), PERL_MAGIC_ext, NULL, NULL, HeHASH(key));
	magic->mg_private = 0x414d;
}

MODULE = Accessors::Magic				PACKAGE = Accessors::Magic

PROTOTYPES: DISABLED

BOOT:
	hv_store(PL_modglobal, "Accessors::Magic", 16, (SV*)newHV(), 0);

void
add_accessor(package, name, rename = name)
	SV* package;
	SV* name;
	SV* rename;
	CODE:
		add_accessor(aTHX_ package, name, rename, magic_accessor);

void
add_reader(package, name, rename = name)
	SV* package;
	SV* name;
	SV* rename;
	CODE:
		add_accessor(aTHX_ package, name, rename, magic_reader);

void
add_writer(package, name, rename = name)
	SV* package;
	SV* name;
	SV* rename;
	CODE:
		add_accessor(aTHX_ package, name, rename, magic_writer);

