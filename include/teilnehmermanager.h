#ifndef TEILNEHMERMANAGER_H
#define TEILNEHMERMANAGER_H

#include "person.h"

#include <managercontext.h>

#include <vector>

class TeilnehmerManager
{
    public:
        explicit TeilnehmerManager(ManagerContext& ctx)
            : _ctx(ctx)
        { }

        std::vector<Person> searchPerson(unsigned vid, const std::string& s);

    private:
        ManagerContext& _ctx;
};

#endif
