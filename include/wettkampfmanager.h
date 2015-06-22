/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#ifndef WETTKAMPFMANAGER_H
#define WETTKAMPFMANAGER_H

#include "wettkampf.h"

#include <tntdb/connection.h>

#include <vector>

class WettkampfManager
{
    public:
        WettkampfManager(tntdb::Connection conn)
            : _conn(conn)
        { }

        std::vector<Wettkampf> getWettkaempfe(unsigned vid);

    private:
        tntdb::Connection _conn;
};

#endif // WETTKAMPFMANAGER_H

