/*
 * Copyright (C) 2016 Tommi Maekitalo
 *
 */

#include <person.h>
#include <cxxtools/serializationinfo.h>
#include <cxxtools/utf8.h>

void operator>>= (const cxxtools::SerializationInfo& si, Person& p)
{
    si.getMember("pid") >>= p.pid;
    si.getMember("nachname") >>= cxxtools::Utf8(p.nachname);
    si.getMember("vorname") >>= cxxtools::Utf8(p.vorname);
    si.getMember("verein") >>= cxxtools::Utf8(p.verein);
    si.getMember("geschlecht") >>= p.geschlecht;
    si.getMember("jahrgang") >>= p.jahrgang;
    si.getMember("strasse") >>= cxxtools::Utf8(p.strasse);
    si.getMember("plz") >>= cxxtools::Utf8(p.plz);
    si.getMember("ort") >>= cxxtools::Utf8(p.ort);
    si.getMember("land") >>= cxxtools::Utf8(p.land);
    si.getMember("nationalitaet") >>= cxxtools::Utf8(p.nationalitaet);
}

void operator<<= (cxxtools::SerializationInfo& si, const Person& p)
{
    si.addMember("pid") <<= p.pid;
    si.addMember("nachname") <<= cxxtools::Utf8(p.nachname);
    si.addMember("vorname") <<= cxxtools::Utf8(p.vorname);
    si.addMember("verein") <<= cxxtools::Utf8(p.verein);
    si.addMember("geschlecht") <<= p.geschlecht;
    si.addMember("jahrgang") <<= p.jahrgang;
    si.addMember("strasse") <<= cxxtools::Utf8(p.strasse);
    si.addMember("plz") <<= cxxtools::Utf8(p.plz);
    si.addMember("ort") <<= cxxtools::Utf8(p.ort);
    si.addMember("land") <<= cxxtools::Utf8(p.land);
    si.addMember("nationalitaet") <<= cxxtools::Utf8(p.nationalitaet);
}
