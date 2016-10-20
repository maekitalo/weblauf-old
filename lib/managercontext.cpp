/*
 * Copyright (C) 2016 Tommi Maekitalo
 *
 */

#include <managercontext.h>
#include <managercontextimpl.h>
#include <configuration.h>
#include <tntdb/connect.h>

ManagerContextImpl& ManagerContext::impl()
{
    if (!_impl)
        _impl = new ManagerContextImpl();
    return *_impl;
}

tntdb::Connection& ManagerContextImpl::conn()
{
    if (!_conn)
    {
        const Configuration& configuration = Configuration::it();
        _conn = tntdb::connectCached(configuration.dburl());
    }

    return _conn;
}
