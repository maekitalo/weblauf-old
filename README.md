Tntnet Projekt Weblauf2
=======================

Weblauf ist eine Applikation zum Auswerten von Leichtathletikveranstaltungen. Es
ist seit vielen Jahren bei der LG Bad Soden/Sulzbach/Neuenhain im Einsatz und
wird permanent weiter entwickelt. Das bisherige Programm ist mit HTML::Mason
entwickelt. HTML::Mason ist ein Template System, welches es erlaubt, Perl in
HTML einzubetten. Da Perl nicht wirklich für grössere Projekte gut geeigent ist,
ist die Idee gekommen, das ganze mit C++ neu zu implementieren. Aus dieser Idee
heraus ist [Tntnet](http://www.tntnet.org/) entstanden.

Da Weblauf schon damals (also im Herbst 2003) bereits recht umfangreich war und
sich andere Anwendungsgebiete für Tntnet ergeben haben, wurde Weblauf entgegen
der Idee nie auf Tntnet portiert.

Dieses vorliegende Projekt Weblauf2 soll dieses nach holen. Damit soll das MVC
Pattern, welches für Tntnet entwickelt wurde, in einem grösseren öffentlichen
Projekt zum Einsatz kommen.

Das Projekt verwendet wie auch schon das Vorgängerprojekt PostgreSQL als
Datenbank. Das Datenbankmodell wird beibehalten, so dass beide Systeme auch
parallel laufen können.

In der Datenbank wird plperl für ein paar Kleinigkeiten verwendet. Das soll in
diesem Projekt nicht mehr notwendig sein, so dass statt PostgreSQL auch ein
anderes von tntdb unterstützte Datenbanksystem zum Einsatz kommen könnte.

Das Perl-basierte Weblauf wurde nie veröffentlicht. Bei Interesse stelle ich es
aber gerne zur Verfügung.
