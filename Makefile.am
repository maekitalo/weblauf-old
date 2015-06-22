ACLOCAL_AMFLAGS = -I m4 --install
AUTOMAKE_OPTIONS = subdir-objects
AM_CPPFLAGS = -I$(top_srcdir)/include

bin_PROGRAMS = weblauf

lib_LTLIBRARIES = libweblauf.la

libweblauf_la_SOURCES = \
	lib/veranstaltung.cpp \
	lib/veranstaltungmanager.cpp \
	lib/wettkampfmanager.cpp \
	lib/wettkampf.cpp \
	lib/wertung.cpp \
	lib/wertungsgruppe.cpp \
	lib/wertungmanager.cpp

include_HEADERS = \
	configuration.h \
	actionreply.h \
	include/veranstaltung.h \
	include/veranstaltungmanager.h \
	include/wettkampf.h \
	include/wettkampfmanager.h \
	include/wertung.h \
	include/wertungmanager.h

noinst_HEADERS = \
	model/index.ecpp \
	model/veranstaltung.ecpp \
	session.ecpp

ecppSources = \
	actionmain.ecpp \
	action/setwertung.ecpp \
	action/setwettkampf.ecpp \
	controller/index.ecpp \
	controller/veranstaltung.ecpp \
	controller/wettkampf.ecpp \
	controller/wertung.ecpp \
	controller/wgruppe.ecpp \
	html/veranstaltung.ecpp \
	json/setveranstaltung.ecpp \
	view/index.ecpp \
	view/veranstaltung.ecpp \
	view/wertung.ecpp \
	view/wettkampf.ecpp \
	view/wgruppe.ecpp \
	webmain.ecpp

staticSources = \
	resources/dropdown.css \
	resources/images/sort_asc.png \
	resources/images/sort_desc.png \
	resources/images/sort_both.png \
	resources/jquery-2.1.4.min.js \
	resources/jquery-2.1.4.js \
	resources/jquery.dataTables.min.js \
	resources/jquery.dataTables.min.css \
	resources/jquery-ui-1.11.4.custom/jquery-ui.js \
	resources/jquery-ui-1.11.4.custom/jquery-ui.theme.css \
	resources/jquery-ui-1.11.4.custom/jquery-ui.css \
	resources/jquery-ui-1.11.4.custom/jquery-ui.structure.min.css \
	resources/jquery-ui-1.11.4.custom/jquery-ui.structure.css \
	resources/jquery-ui-1.11.4.custom/jquery-ui.min.js \
	resources/jquery-ui-1.11.4.custom/images/ui-icons_ffffff_256x240.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_flat_10_000000_40x100.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_diagonals-thick_18_b81900_40x40.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_highlight-soft_100_eeeeee_1x100.png \
	resources/jquery-ui-1.11.4.custom/images/ui-icons_228ef1_256x240.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_glass_100_f6f6f6_1x400.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_gloss-wave_35_f6a828_500x100.png \
	resources/jquery-ui-1.11.4.custom/images/ui-icons_222222_256x240.png \
	resources/jquery-ui-1.11.4.custom/images/ui-icons_ef8c08_256x240.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_highlight-soft_75_ffe45c_1x100.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_glass_100_fdf5ce_1x400.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_glass_65_ffffff_1x400.png \
	resources/jquery-ui-1.11.4.custom/images/ui-bg_diagonals-thick_20_666666_40x40.png \
	resources/jquery-ui-1.11.4.custom/images/ui-icons_ffd27a_256x240.png \
	resources/jquery-ui-1.11.4.custom/index.html \
	resources/jquery-ui-1.11.4.custom/jquery-ui.theme.min.css \
	resources/jquery-ui-1.11.4.custom/jquery-ui.min.css \
	resources/js/noty/packaged/jquery.noty.packaged.min.js \
	resources/js/noty/packaged/jquery.noty.packaged.js \
	resources/js/noty/layouts/topLeft.js \
	resources/js/noty/layouts/centerLeft.js \
	resources/js/noty/layouts/bottom.js \
	resources/js/noty/layouts/topCenter.js \
	resources/js/noty/layouts/center.js \
	resources/js/noty/layouts/top.js \
	resources/js/noty/layouts/bottomCenter.js \
	resources/js/noty/layouts/topRight.js \
	resources/js/noty/layouts/centerRight.js \
	resources/js/noty/layouts/bottomLeft.js \
	resources/js/noty/layouts/inline.js \
	resources/js/noty/layouts/bottomRight.js \
	resources/js/noty/jquery.noty.js \
	resources/js/noty/promise.js \
	resources/js/noty/themes/bootstrap.js \
	resources/js/noty/themes/relax.js \
	resources/js/noty/themes/default.js \
	resources/veranstaltung.js \
	resources/weblauf.css \
	resources/wertung.js \
	resources/wettkampf.js \
	resources/weblauf.js

weblauf_SOURCES = \
	main.cpp \
	configuration.cpp \
	$(ecppSources)

nodist_weblauf_SOURCES = \
	resources.cpp

weblauf_LDFLAGS = -lcxxtools -ltntnet -ltntdb

weblauf_LDADD = $(top_builddir)/libweblauf.la

nobase_dist_noinst_DATA = $(staticSources)

CLEANFILES = $(ecppSources:.ecpp=.cpp) $(ecppSources:.ecpp=.deps) resources.cpp

EXTRA_DIST = $(staticSources)

#
# Rules for tntnet applications
#

ECPPFLAGS=-I$(srcdir)

# resources
resources.cpp: $(staticSources) Makefile.am
	$(AM_V_GEN)$(ECPPC) -bb -z -n resources -p -o resources.cpp $(ECPPFLAGS) $(staticSources)

SUFFIXES=.ecpp .cpp

.ecpp.cpp:
	$(AM_V_GEN)$(ECPPC) -n `echo $<|$(SED) 's|^$(srcdir)/||; s|\.ecpp$$||'` $(ECPPFLAGS) -o $@ $<
.ecpp.deps:
	$(AM_V_GEN)$(ECPPC) -M $(ECPPFLAGS) $< | $(SED) '1s/\(.*\).cpp:/\1.cpp \1.deps:/' > $@

-include $(ecppSources:.ecpp=.deps)
