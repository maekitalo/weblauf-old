/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#ifndef WERTUNGMANAGER_H
#define WERTUNGMANAGER_H

#include "wertung.h"

#include <tntdb/connection.h>

#include <vector>

class WertungManager
{
    public:
        WertungManager(tntdb::Connection conn)
            : _conn(conn)
        { }

        std::vector<Wertung> getWertungen(unsigned vid, unsigned wid);

    private:
        tntdb::Connection _conn;
};

#endif // WERTUNGMANAGER_H

