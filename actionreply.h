#ifndef ACTIONREPLY_H
#define ACTIONREPLY_H

#include "noty.h"

class ActionReply : public Noty
{
    friend void operator <<= (cxxtools::SerializationInfo& si, const ActionReply& reply);

public:
    ActionReply()
        : _success(true)
        { }

    void setSuccess(const cxxtools::String& m = cxxtools::String())
    {
        _success = true;
        if (!m.empty())
            success(m);
    }

    void setSuccess(const std::string& m)
    {
        _success = true;
        success(m);
    }

    void setFailed(const cxxtools::String& m)
    {
        _success = false;
        error(m);
    }

    void setFailed(const std::string& m)
    {
        _success = false;
        error(m);
    }

private:
    bool _success;
};

inline void operator <<= (cxxtools::SerializationInfo& si, const ActionReply& reply)
{
    si.addMember("success") <<= reply._success;
    si.addMember("notifications") <<= static_cast<const Noty&>(reply);
}

#endif // ACTIONREPLY_H

