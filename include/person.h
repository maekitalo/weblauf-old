/*
 * Copyright (C) 2016 Tommi Maekitalo
 *
 */

#ifndef PERSON_H
#define PERSON_H

#include <string>

namespace cxxtools
{
    class SerializationInfo;
}

struct Person
{
    unsigned pid;
    std::string nachname;
    std::string vorname;
    std::string verein;
    char geschlecht;
    unsigned jahrgang;
    std::string strasse;
    std::string plz;
    std::string ort;
    std::string land;
    std::string nationalitaet;

    bool maennlich() const   { return geschlecht == 'M'; }
    bool weiblich() const    { return geschlecht == 'W'; }
};

void operator>>= (const cxxtools::SerializationInfo& si, Person& p);

void operator<<= (cxxtools::SerializationInfo& si, const Person& p);

#endif
