/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#include "wertungmanager.h"

#include <managercontextimpl.h>

#include <tntdb/connection.h>
#include <tntdb/statement.h>
#include <tntdb/row.h>

#include <cxxtools/log.h>

log_define("weblauf.wertung.manager")

Wertung WertungManager::getWertung(unsigned vid, unsigned wid, unsigned rid)
{
    log_debug("getWertung(" << vid << ", " << wid << ", " << rid << ')');

    tntdb::Statement st = _ctx.impl().conn().prepareCached(R"SQL(
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
    log_debug("getWertungen(" << vid << ", " << wid << ')');

    tntdb::Statement st = _ctx.impl().conn().prepareCached(R"SQL(
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

    log_debug(wertungen.size() << " Wertungen");

    return wertungen;
}

Wertungsgruppe WertungManager::getWertungsgruppe(unsigned vid, unsigned wid, unsigned gid)
{
    log_debug("getWertungsgruppe(" << vid << ", " << wid << ", " << gid << ')');

    Wertungsgruppe wertungsgruppe;

    tntdb::Statement st = _ctx.impl().conn().prepareCached(R"SQL(
        select wgr_name, wgw_rid
          from wgruppe
          left outer join wgruppewer
            on wgr_vid = wgw_vid
           and wgr_wid = wgw_wid
           and wgr_gid = wgw_gid
         where vid = :vid
           and wid = :wid
           and gid = :gid
        )SQL");

    st.set("vid", vid)
      .set("wid", wid)
      .set("gid", gid);

    wertungsgruppe.vid = vid;
    wertungsgruppe.wid = wid;
    wertungsgruppe.gid = gid;

    for (auto r: st)
    {
        r[0].get(wertungsgruppe.name);
        unsigned rid;
        if (r[1].get(rid))
            wertungsgruppe.rid.push_back(rid);
    }

    return wertungsgruppe;
}

std::vector<Wertungsgruppe> WertungManager::getWertungsgruppen(unsigned vid, unsigned wid)
{
    log_debug("getWertungsgruppen(" << vid << ", " << wid << ')');

    std::vector<Wertungsgruppe> wertungsgruppen;

    tntdb::Statement st = _ctx.impl().conn().prepareCached(R"SQL(
        select wgr_gid, wgr_name, wgw_rid
          from wgruppe
          left outer join wgruppewer
            on wgr_vid = wgw_vid
           and wgr_wid = wgw_wid
           and wgr_gid = wgw_gid
         where wgr_vid = :vid
           and wgr_wid = :wid
        )SQL");

    st.set("vid", vid)
      .set("wid", wid);

    unsigned gid = 0;

    for (auto r: st)
    {
        r[0].get(gid);

        if (wertungsgruppen.empty() || wertungsgruppen.back().gid != gid)
        {
            wertungsgruppen.emplace_back();
            auto& w = wertungsgruppen.back();
            w.vid = vid;
            w.wid = wid;
            w.gid = gid;
        }

        auto& w = wertungsgruppen.back();
        r[1].get(w.name);

        unsigned rid;
        if (r[2].get(rid))
            w.rid.push_back(rid);
    }

    log_debug(wertungsgruppen.size() << " Wertungsgruppen");

    return wertungsgruppen;
}
