/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#ifndef VERANSTALTUNGMANAGER_H
#define VERANSTALTUNGMANAGER_H

#include "veranstaltung.h"

#include <managercontext.h>

#include <vector>

class VeranstaltungManager
{
    public:
        explicit VeranstaltungManager(ManagerContext& ctx)
            : _ctx(ctx)
        { }

        Veranstaltung getVeranstaltung(unsigned vid);
        std::vector<Veranstaltung> getVeranstaltungen();
        void putVeranstaltung(const Veranstaltung& v);
        void delVeranstaltung(unsigned vid);

    private:
        ManagerContext& _ctx;
};

#endif // VERANSTALTUNGMANAGER_H

