/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#include "veranstaltungmanager.h"
#include <managercontextimpl.h>

#include <tntdb/statement.h>
#include <tntdb/row.h>
#include <tntdb/cxxtools/date.h>

Veranstaltung VeranstaltungManager::getVeranstaltung(unsigned vid)
{
    tntdb::Statement st = _ctx.impl().conn().prepareCached(R"SQL(
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
    tntdb::Statement st = _ctx.impl().conn().prepareCached(R"SQL(
        select van_vid, van_datum, van_name, van_ort, van_logo
          from veranstaltung
          order by van_datum
        )SQL");

    std::vector<Veranstaltung> veranstaltungen;
    for (auto r: st)
    {
        Veranstaltung v;
        r.get(v.vid)
         .get(v.datum)
         .get(v.name)
         .get(v.ort)
         .get(v.logo);

        veranstaltungen.push_back(v);
    }

    return veranstaltungen;
}

void VeranstaltungManager::putVeranstaltung(const Veranstaltung& v)
{
    if (v.isNew())
    {
        tntdb::Statement selvid = _ctx.impl().conn().prepareCached(R"SQL(
            select max(van_vid)
              from veranstaltung
            )SQL");

        tntdb::Statement ins = _ctx.impl().conn().prepareCached(R"SQL(
            insert into veranstaltung
                (van_vid, van_datum, van_name, van_ort, van_logo)
            values
                (:vid, :datum, :name, :ort, :logo)
            )SQL");

        unsigned vid = 0;
        selvid.selectValue()
              .get(vid);

        ins.set("vid", vid + 1)
           .set("name", v.name)
           .set("datum", v.datum)
           .set("ort", v.ort)
           .set("logo", v.logo)
           .execute();
    }
    else
    {
        tntdb::Statement upd = _ctx.impl().conn().prepareCached(R"SQL(
            update veranstaltung
               set van_name = :name,
                   van_datum = :datum,
                   van_ort = :ort,
                   van_logo = :logo
             where van_vid = :vid
            )SQL");

        upd.set("vid", v.vid)
           .set("name", v.name)
           .set("datum", v.datum)
           .set("ort", v.ort)
           .set("logo", v.logo)
           .execute();
    }

}

void VeranstaltungManager::delVeranstaltung(unsigned vid)
{
    tntdb::Statement del = _ctx.impl().conn().prepareCached(R"SQL(
        delete from veranstaltung
         where van_vid = :vid
        )SQL");

    del.set("vid", vid)
       .execute();
}
