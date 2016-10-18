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
        explicit VeranstaltungManager(tntdb::Connection conn)
            : _conn(conn)
        { }

        Veranstaltung getVeranstaltung(unsigned vid);
        std::vector<Veranstaltung> getVeranstaltungen();
        void putVeranstaltung(const Veranstaltung& v);
        void delVeranstaltung(unsigned vid);

    private:
        tntdb::Connection _conn;
};

#endif // VERANSTALTUNGMANAGER_H

