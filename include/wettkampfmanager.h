/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#ifndef WETTKAMPFMANAGER_H
#define WETTKAMPFMANAGER_H

#include "wettkampf.h"

#include <managercontext.h>

#include <vector>

class WettkampfManager
{
    public:
        explicit WettkampfManager(ManagerContext& ctx)
            : _ctx(ctx)
            { }

        Wettkampf getWettkampf(unsigned vid, unsigned wid);
        std::vector<Wettkampf> getWettkaempfe(unsigned vid);

    private:
        ManagerContext& _ctx;
};

#endif // WETTKAMPFMANAGER_H
