/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#ifndef VERANSTALTUNGMANAGER_H
#define VERANSTALTUNGMANAGER_H

#include "veranstaltung.h"

#include <tntdb/connection.h>

#include <vector>

class VeranstaltungManager
{
    public:
        VeranstaltungManager(tntdb::Connection conn)
            : _conn(conn)
        { }

        std::vector<Veranstaltung> getVeranstaltungen();

    private:
        tntdb::Connection _conn;
};

#endif // VERANSTALTUNGMANAGER_H

