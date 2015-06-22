/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#include "wertungmanager.h"

#include <tntdb/connection.h>
#include <tntdb/statement.h>
#include <tntdb/row.h>

Wertung WertungManager::getWertung(unsigned vid, unsigned wid, unsigned rid)
{
    tntdb::Statement st = _conn.prepareCached(R"SQL(
        select wer_rid, wer_name, wer_abhaengig, wer_urkunde, wer_preis
          from wertung
         where wer_vid = :vid
           and wer_wid = :wid
           and wer_rid = :rid
        )SQL");

    Wertung wertung;
    wertung.vid = vid;
    wertung.wid = wid;

    st.set("vid", vid)
      .set("wid", wid)
      .set("rid", rid)
      .selectRow()
      .get(wertung.rid)
      .get(wertung.name)
      .get(wertung.abhaengig)
      .get(wertung.urkunde)
      .get(wertung.preis);

    return wertung;
}

std::vector<Wertung> WertungManager::getWertungen(unsigned vid, unsigned wid)
{
    tntdb::Statement st = _conn.prepareCached(R"SQL(
        select w.wer_rid, w.wer_name, a.wer_name, w.wer_urkunde, w.wer_preis
          from wertung w
          left outer join wertung a
            on a.wer_vid = w.wer_vid
           and a.wer_wid = w.wer_wid
           and a.wer_rid = w.wer_abhaengig
         where w.wer_vid = :vid
           and w.wer_wid = :wid
          order by w.wer_rid
        )SQL");

    st.set("vid", vid)
      .set("wid", wid);

    std::vector<Wertung> wertungen;

    for (auto r: st)
    {
        wertungen.resize(wertungen.size() + 1);
        auto& w = wertungen.back();
        w.vid = vid;
        w.wid = wid;
        r.get(w.rid)
         .get(w.name)
         .get(w.abhaengig)
         .get(w.urkunde)
         .get(w.preis);
    }

    return wertungen;
}
