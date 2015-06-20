#include <veranstaltung.h>
#include <cxxtools/serializationinfo.h>
#include <cxxtools/utf8.h>

void operator>>= (const cxxtools::SerializationInfo& si, Veranstaltung& v)
{
  si.getMember("vid") >>= v.vid;
  si.getMember("name") >>= cxxtools::Utf8(v.name);
  si.getMember("datum") >>= v.datum;
  si.getMember("ort") >>= cxxtools::Utf8(v.ort);
  si.getMember("logo") >>= cxxtools::Utf8(v.logo);
}

void operator<<= (cxxtools::SerializationInfo& si, const Veranstaltung& v)
{
  si.setTypeName("Veranstaltung");

  si.addMember("vid") <<= v.vid;
  si.addMember("name") <<= cxxtools::Utf8(v.name);
  si.addMember("datum") <<= v.datum;
  si.addMember("ort") <<= cxxtools::Utf8(v.ort);
  si.addMember("logo") <<= cxxtools::Utf8(v.logo);
}
