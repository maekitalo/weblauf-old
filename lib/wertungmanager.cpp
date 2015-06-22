/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#include "wertungmanager.h"

#include <tntdb/connection.h>
#include <tntdb/statement.h>
#include <tntdb/row.h>

std::vector<Wertung> WertungManager::getWertungen(unsigned vid, unsigned wid)
{
    tntdb::Statement st = _conn.prepareCached(
        "select w.wer_rid, w.wer_name, a.wer_name, w.wer_urkunde, w.wer_preis"
        "  from wertung w"
        "  left outer join wertung a"
        "    on a.wer_vid = w.wer_vid"
        "   and a.wer_wid = w.wer_wid"
        "   and a.wer_rid = w.wer_abhaengig"
        " where w.wer_vid = :vid"
        "   and w.wer_wid = :wid"
        "  order by w.wer_rid");

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
