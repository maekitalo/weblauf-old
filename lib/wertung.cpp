#include <wertung.h>
#include <cxxtools/serializationinfo.h>
#include <cxxtools/utf8.h>

void operator>>= (const cxxtools::SerializationInfo& si, Wertung& w)
{
  si.getMember("vid") >>= w.vid;
  si.getMember("wid") >>= w.wid;
  si.getMember("rid") >>= w.rid;
  si.getMember("name") >>= cxxtools::Utf8(w.name);
  std::string abhaengig;
  si.getMember("abhaengig", abhaengig);
  w.abhaengig = cxxtools::Utf8(abhaengig);
  si.getMember("urkunde") >>= cxxtools::Utf8(w.urkunde);
  si.getMember("preis") >>= cxxtools::Utf8(w.preis);
}

void operator<<= (cxxtools::SerializationInfo& si, const Wertung& w)
{
  si.addMember("vid") <<= w.vid;
  si.addMember("wid") <<= w.wid;
  si.addMember("rid") <<= w.rid;
  si.addMember("name") <<= cxxtools::Utf8(w.name);
  if (w.haveAbhaengig())
    si.addMember("abhaengig") <<= cxxtools::Utf8(w.abhaengig);
  si.addMember("urkunde") <<= cxxtools::Utf8(w.urkunde);
  si.addMember("preis") <<= cxxtools::Utf8(w.preis);
}
