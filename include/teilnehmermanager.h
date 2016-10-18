#ifndef TEILNEHMERMANAGER_H
#define TEILNEHMERMANAGER_H

#include "person.h"

#include <tntdb/connection.h>

#include <vector>

class TeilnehmerManager
{
    public:
        explicit TeilnehmerManager(tntdb::Connection conn)
            : _conn(conn)
        { }

        std::vector<Person> searchPerson(unsigned vid, const std::string& s);

    private:
        tntdb::Connection _conn;
};

#endif
