/*
 * Copyright (C) 2016 Tommi Maekitalo
 *
 */

#include <iostream>

#include "teilnehmermanager.h"

#include <tntdb/statement.h>
#include <tntdb/row.h>

#include <cxxtools/regex.h>
#include <cxxtools/convert.h>
#include <cxxtools/log.h>

log_define("teilnehmer.manager")

std::vector<Person> TeilnehmerManager::searchPerson(unsigned vid, const std::string& s)
{
    static cxxtools::Regex isnumber("^[0-9]+$");

    tntdb::Statement sel;

    if (isnumber.match(s))
    {
        log_debug("suche nach Startnummer <" << s << '>');

        sel = _conn.prepareCached(R"SQL(
            select per_pid, per_nachname, per_vorname, per_verein, per_geschlecht,
                   per_jahrgang, per_strasse, per_plz, per_ort, per_land,
                   per_nationalitaet
              from person
              left outer join startnummer
                on sta_pid = per_pid
               and sta_vid = :vid
             where per_nachname like :search || '%'
                or per_vorname like :search || '%'
                or sta_snr = :startnummer
            )SQL");

        sel.set("vid", vid)
           .set("startnummer", cxxtools::convert<unsigned>(s));
    }
    else
    {
        log_debug("suche nach Name <" << s << '>');

        sel = _conn.prepareCached(R"SQL(
            select per_pid, per_nachname, per_vorname, per_verein, per_geschlecht,
                   per_jahrgang, per_strasse, per_plz, per_ort, per_land,
                   per_nationalitaet
              from person
             where per_nachname like :search || '%'
                or per_vorname like :search || '%'
            )SQL");
    }

    std::vector<Person> personen;

    sel.set("search", s);

    for (auto r: sel)
    {
        log_debug("lese person");

        Person p;
        r.get(p.pid)
         .get(p.nachname)
         .get(p.vorname)
         .get(p.verein)
         .get(p.geschlecht)
         .get(p.jahrgang)
         .get(p.strasse)
         .get(p.plz)
         .get(p.ort)
         .get(p.land)
         .get(p.nationalitaet);

        personen.push_back(p);
    }

    log_debug(personen.size() << " personen gefunden");

    return personen;
}
