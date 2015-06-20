/*
 * Copyright (C) 2010 Tommi Maekitalo
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * is provided AS IS, WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, and
 * NON-INFRINGEMENT.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
 *
 */

#include <wettkampf.h>
#include <cxxtools/serializationinfo.h>
#include <cxxtools/utf8.h>

void operator>>= (const cxxtools::SerializationInfo& si, Wettkampf& w)
{
  si.getMember("vid") >>= w.vid;
  si.getMember("wid") >>= w.wid;
  si.getMember("name") >>= cxxtools::Utf8(w.name);
  si.getMember("art") >>= w.art;
  si.getMember("staVon") >>= w.staVon;
  si.getMember("staBis") >>= w.staBis;
  si.getMember("startzeit") >>= w.startzeit;
}

void operator<<= (cxxtools::SerializationInfo& si, const Wettkampf& w)
{
  si.addMember("vid") <<= w.vid;
  si.addMember("wid") <<= w.wid;
  si.addMember("name") <<= cxxtools::Utf8(w.name);
  si.addMember("art") <<= w.art;
  si.addMember("staVon") <<= w.staVon;
  si.addMember("staBis") <<= w.staBis;
  si.addMember("startzeit") <<= w.startzeit;
}
