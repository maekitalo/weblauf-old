/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#include "wettkampfmanager.h"

#include <tntdb/statement.h>
#include <tntdb/row.h>
#include <tntdb/cxxtools/time.h>

Wettkampf WettkampfManager::getWettkampf(unsigned vid, unsigned wid)
{
    tntdb::Statement st = _conn.prepareCached(
        "select wet_wid, wet_name, wet_art, wet_sta_von, wet_sta_bis, wet_startzeit"
        "  from wettkampf"
        " where wet_vid = :vid"
        "   and wet_wid = :wid");

    Wettkampf wettkampf;
    wettkampf.vid = vid;

    st.set("vid", vid)
      .set("wid", wid)
      .selectRow()
      .get(wettkampf.wid)
      .get(wettkampf.name)
      .get(wettkampf.art)
      .get(wettkampf.staVon)
      .get(wettkampf.staBis)
      .get(wettkampf.startzeit);

    return wettkampf;
}

std::vector<Wettkampf> WettkampfManager::getWettkaempfe(unsigned vid)
{
    tntdb::Statement st = _conn.prepareCached(
        "select wet_wid, wet_name, wet_art, wet_sta_von, wet_sta_bis, wet_startzeit"
        "  from wettkampf"
        " where wet_vid = :vid"
        "  order by wet_wid");

    st.set("vid", vid);

    std::vector<Wettkampf> wettkaempfe;
    for (auto r: st)
    {
        wettkaempfe.resize(wettkaempfe.size() + 1);
        auto& w = wettkaempfe.back();
        w.vid = vid;
        r.get(w.wid)
         .get(w.name)
         .get(w.art)
         .get(w.staVon)
         .get(w.staBis)
         .get(w.startzeit);
    }

    return wettkaempfe;
}
