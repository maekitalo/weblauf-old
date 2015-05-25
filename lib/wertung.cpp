#include <wertung.h>
#include <cxxtools/serializationinfo.h>

void operator>>= (const cxxtools::SerializationInfo& si, Wertung& w)
{
  si.getMember("vid") >>= w.vid;
  si.getMember("wid") >>= w.wid;
  si.getMember("rid") >>= w.rid;
  si.getMember("name") >>= w.name;
  if (!si.getMember("abhaengig", w.abhaengig))
    w.clearAbhaengig();
  si.getMember("urkunde") >>= w.urkunde;
  si.getMember("preis") >>= w.preis;
}

void operator<<= (cxxtools::SerializationInfo& si, const Wertung& w)
{
  si.addMember("vid") <<= w.vid;
  si.addMember("wid") <<= w.wid;
  si.addMember("rid") <<= w.rid;
  si.addMember("name") <<= w.name;
  if (w.haveAbhaengig())
    si.addMember("abhaengig") <<= w.abhaengig;
  si.addMember("urkunde") <<= w.urkunde;
  si.addMember("preis") <<= w.preis;
}
