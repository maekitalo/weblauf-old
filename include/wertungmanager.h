/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#ifndef WERTUNGMANAGER_H
#define WERTUNGMANAGER_H

#include "wertung.h"
#include "wertungsgruppe.h"

#include <tntdb/connection.h>

#include <vector>

class WertungManager
{
    public:
        WertungManager(tntdb::Connection conn)
            : _conn(conn)
        { }

        Wertung getWertung(unsigned vid, unsigned wid, unsigned rid);
        std::vector<Wertung> getWertungen(unsigned vid, unsigned wid);

        Wertungsgruppe getWertungsgruppe(unsigned vid, unsigned wid, unsigned gid);
        std::vector<Wertungsgruppe> getWertungsgruppen(unsigned vid, unsigned wid);

    private:
        tntdb::Connection _conn;
};

#endif // WERTUNGMANAGER_H

