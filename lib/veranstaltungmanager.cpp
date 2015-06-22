/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#include "veranstaltungmanager.h"

#include <tntdb/statement.h>
#include <tntdb/row.h>
#include <tntdb/cxxtools/date.h>

std::vector<Veranstaltung> VeranstaltungManager::getVeranstaltungen()
{
    tntdb::Statement st = _conn.prepareCached(
        "select van_vid, van_datum, van_name, van_ort, van_logo"
        "  from veranstaltung"
        "  order by van_datum");

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
