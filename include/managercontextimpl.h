/*
 * Copyright (C) 2016 Tommi Maekitalo
 *
 */

#ifndef MANAGERCONTECTIMPL_H
#define MANAGERCONTECTIMPL_H

#include <tntdb/connection.h>

class ManagerContextImpl
{
public:
    tntdb::Connection& conn();

private:
    tntdb::Connection _conn;
};

#endif // MANAGERCONTECTIMPL_H
