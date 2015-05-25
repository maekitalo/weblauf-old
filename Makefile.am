ACLOCAL_AMFLAGS = -I m4 --install
AUTOMAKE_OPTIONS = subdir-objects
AM_CPPFLAGS = -I$(top_srcdir)/include

bin_PROGRAMS = weblauf

lib_LTLIBRARIES = libweblauf.la

libweblauf_la_SOURCES = \
	lib/veranstaltung.cpp \
	lib/wettkampf.cpp \
	lib/wertung.cpp

include_HEADERS = \
	configuration.h \
	include/veranstaltung.h \
	include/wettkampf.h
	include/wertung.h

noinst_HEADERS = \
	model/index.ecpp \
	model/veranstaltung.ecpp \
	session.ecpp

ecppSources = \
	controller/index.ecpp \
	controller/veranstaltung.ecpp \
	controller/wettkampf.ecpp \
	controller/wertung.ecpp \
	json/setveranstaltung.ecpp \
	json/setwertung.ecpp \
	json/setwettkampf.ecpp \
	view/index.ecpp \
	view/veranstaltung.ecpp \
	view/wettkampf.ecpp \
	view/wertung.ecpp \
	webmain.ecpp

staticSources = \
	resources/dropdown.css \
	resources/jquery-2.1.4.min.js \
	resources/jquery.dataTables.min.js \
	resources/jquery.dataTables.min.css \
	resources/veranstaltung.js \
	resources/weblauf.css \
	resources/wertung.js \
	resources/wettkampf.js \
	resources/images/sort_asc.png \
	resources/images/sort_desc.png \
	resources/images/sort_both.png \
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
