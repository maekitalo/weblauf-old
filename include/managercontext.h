/*
 * Copyright (C) 2016 Tommi Maekitalo
 *
 */

#ifndef MANAGERCONTEXT_H
#define MANAGERCONTEXT_H

class ManagerContextImpl;

class ManagerContext
{
    ManagerContext(const ManagerContext&) = delete;
    ManagerContext& operator=(const ManagerContext&) = delete;

public:
    ManagerContext()
        : _impl(0)
        { }

    ManagerContextImpl& impl();

private:
    ManagerContextImpl* _impl;
};

#endif // MANAGERCONTEXT_H
