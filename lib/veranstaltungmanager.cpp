/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#include "veranstaltungmanager.h"

#include <tntdb/statement.h>
#include <tntdb/row.h>
#include <tntdb/cxxtools/date.h>

Veranstaltung VeranstaltungManager::getVeranstaltung(unsigned vid)
{
    tntdb::Statement st = _conn.prepareCached(R"SQL(
        select van_vid, van_datum, van_name, van_ort, van_logo
          from veranstaltung
         where van_vid = :vid
        )SQL");

    Veranstaltung veranstaltung;

    st.set("vid", vid)
      .selectRow()
      .get(veranstaltung.vid)
      .get(veranstaltung.datum)
      .get(veranstaltung.name)
      .get(veranstaltung.ort)
      .get(veranstaltung.logo);

    return veranstaltung;
}

std::vector<Veranstaltung> VeranstaltungManager::getVeranstaltungen()
{
    tntdb::Statement st = _conn.prepareCached(R"SQL(
        select van_vid, van_datum, van_name, van_ort, van_logo
          from veranstaltung
          order by van_datum
        )SQL");

    std::vector<Veranstaltung> veranstaltungen;
    for (auto r: st)
    {
        veranstaltungen.resize(veranstaltungen.size() + 1);
        auto& v = veranstaltungen.back();
        r.get(v.vid)
         .get(v.datum)
         .get(v.name)
         .get(v.ort)
         .get(v.logo);
    }

    return veranstaltungen;
}
