#include <wertungsgruppe.h>
#include <cxxtools/serializationinfo.h>
#include <cxxtools/utf8.h>

void operator>>= (const cxxtools::SerializationInfo& si, Wertungsgruppe& g)
{
  si.getMember("vid") >>= g.vid;
  si.getMember("wid") >>= g.wid;
  si.getMember("gid") >>= g.gid;
  si.getMember("name") >>= cxxtools::Utf8(g.name);
  si.getMember("rid") >>= g.rid;
}

void operator<<= (cxxtools::SerializationInfo& si, const Wertungsgruppe& g)
{
  si.addMember("vid") <<= g.vid;
  si.addMember("wid") <<= g.wid;
  si.addMember("gid") <<= g.gid;
  si.addMember("name") <<= cxxtools::Utf8(g.name);
  si.addMember("rid") <<= g.rid;
}
