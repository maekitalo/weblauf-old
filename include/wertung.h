#ifndef WERTUNG_H
#define WERTUNG_H

#include <string>

namespace cxxtools
{
  class SerializationInfo;
}

struct Wertung
{
    static const unsigned nullrid = static_cast<unsigned>(-1);

    unsigned vid;
    unsigned wid;
    unsigned rid;
    std::string name;
    std::string abhaengig;
    std::string urkunde;
    std::string preis; // in cents

    bool haveAbhaengig() const
    { return !abhaengig.empty(); }
    void clearAbhaengig()
    { abhaengig.clear(); }

    Wertung()
      : vid(0),
        wid(0),
        rid(0)
    { }

};

void operator>>= (const cxxtools::SerializationInfo& si, Wertung& v);

void operator<<= (cxxtools::SerializationInfo& si, const Wertung& v);

#endif // WERTUNG_H
