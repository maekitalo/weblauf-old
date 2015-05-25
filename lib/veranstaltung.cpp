#include <veranstaltung.h>
#include <cxxtools/serializationinfo.h>

void operator>>= (const cxxtools::SerializationInfo& si, Veranstaltung& v)
{
  si.getMember("vid") >>= v.vid;
  si.getMember("name") >>= v.name;
  si.getMember("datum") >>= v.datum;
  si.getMember("ort") >>= v.ort;
  si.getMember("logo") >>= v.logo;
}

void operator<<= (cxxtools::SerializationInfo& si, const Veranstaltung& v)
{
  si.setTypeName("Veranstaltung");

  si.addMember("vid") <<= v.vid;
  si.addMember("name") <<= v.name;
  si.addMember("datum") <<= v.datum;
  si.addMember("ort") <<= v.ort;
  si.addMember("logo") <<= v.logo;
}
