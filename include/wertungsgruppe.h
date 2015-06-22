/*
 * Copyright (C) 2015 Tommi Maekitalo
 *
 */

#ifndef WERTUNGSGRUPPE_H
#define WERTUNGSGRUPPE_H

#include <string>
#include <vector>

namespace cxxtools
{
  class SerializationInfo;
}

struct Wertungsgruppe
{
    unsigned vid;
    unsigned wid;
    unsigned gid;
    std::string name;
    std::vector<unsigned> rid;
};

void operator>>= (const cxxtools::SerializationInfo& si, Wertungsgruppe& g);

void operator<<= (cxxtools::SerializationInfo& si, const Wertungsgruppe& g);

#endif // WERTUNGSGRUPPE_H

