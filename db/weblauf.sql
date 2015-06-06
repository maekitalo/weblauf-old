--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plperl; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plperl;


ALTER PROCEDURAL LANGUAGE plperl OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: do_meldung(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: tommi
--

CREATE FUNCTION do_meldung(integer, integer, integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    pid ALIAS FOR $1;
    vid ALIAS FOR $2;
    wid ALIAS FOR $3;
    jahr INTEGER;
    rid INTEGER;
    abhaengig INTEGER;
BEGIN
    -- ermittele Jahr
    SELECT INTO jahr
           date_part('year', van_datum)
      FROM veranstaltung
     WHERE van_vid = vid;

    -- ermittele Wertung mit der höchsten Priorität
    SELECT INTO rid, abhaengig
           wea_rid, wer_abhaengig
      FROM wertungak
      JOIN klasse
        ON wea_ak = kls_ak
      LEFT OUTER JOIN wertung
        ON wer_vid = wea_vid
       AND wer_wid = wea_wid
       AND wer_rid = wea_rid
      JOIN person
       ON per_geschlecht = kls_geschlecht
     WHERE per_pid = pid
       AND wea_vid = vid
       AND wea_wid = wid
       AND (jahr - per_jahrgang) BETWEEN kls_alter_von AND kls_alter_bis
     ORDER BY kls_prioritaet DESC
     LIMIT 1;

    -- führe Meldung durch
    --RAISE NOTICE 'rid=%', rid;
    INSERT INTO meldung(mel_pid, mel_vid, mel_wid, mel_rid)
      VALUES (pid, vid, wid, rid);

    -- verarbeite abhängige Meldung
    WHILE abhaengig IS NOT NULL LOOP
        PERFORM SELECT 1
          FROM meldung
         WHERE mel_pid = pid
           AND mel_vid = vid
           AND mel_rid = wid;

        EXIT WHEN FOUND;

        --RAISE NOTICE 'rid(abaengig)=%', abhaengig;
        INSERT INTO meldung(mel_pid, mel_vid, mel_wid, abhaengig)
          VALUES (pid, vid, wid, abhaengig);

        SELECT INTO abhaengig
               wer_abhaengig
          FROM wertung
         WHERE wer_vid = vid
           AND wer_wid = wid
           AND wer_rid = abhaengig;
    END LOOP;

    RETURN rid;
END;
$_$;


ALTER FUNCTION public.do_meldung(integer, integer, integer) OWNER TO tommi;

--
-- Name: do_meldung_snr(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION do_meldung_snr(integer, integer, integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    snr ALIAS FOR $1;
    vid ALIAS FOR $2;
    wid ALIAS FOR $3;
    pid INTEGER;
BEGIN
    SELECT INTO pid
           sta_pid
      FROM startnummer
     WHERE sta_vid = vid
       AND sta_snr = snr;

    RETURN do_meldung(pid, vid, wid);
END;
$_$;


ALTER FUNCTION public.do_meldung_snr(integer, integer, integer) OWNER TO postgres;

--
-- Name: ergebnis_format(character, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ergebnis_format(character, double precision) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    art ALIAS FOR $1;
    wert ALIAS FOR $2;
BEGIN
    IF wert IS NULL THEN
        RETURN NULL;
    ELSIF art = 'L' THEN
        RETURN formatzeit(wert, true);
    ELSIF art = 'W' THEN
        RETURN formatdouble2f(wert) || 'm';
    ELSE
        RETURN NULL;
    END IF;
END;$_$;


ALTER FUNCTION public.ergebnis_format(character, double precision) OWNER TO postgres;

--
-- Name: ergebnis_format(character, double precision, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ergebnis_format(character, double precision, boolean) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    art ALIAS FOR $1;
    wert ALIAS FOR $2;
    hand ALIAS FOR $3;
BEGIN
    IF wert IS NULL THEN
        RETURN NULL;
    ELSIF art = 'L' THEN
        RETURN formatzeit(wert, hand);
    ELSIF art = 'W' THEN
        RETURN formatdouble2f(wert) || 'm';
    ELSE
        RETURN NULL;
    END IF;
END;$_$;


ALTER FUNCTION public.ergebnis_format(character, double precision, boolean) OWNER TO postgres;

--
-- Name: ergebnis_long(character, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ergebnis_long(character, integer, integer, integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    art ALIAS FOR $1;
    vid ALIAS FOR $2;
    wid ALIAS FOR $3;
    snr ALIAS FOR $4;
    erg RECORD;
    ret TEXT;
BEGIN
    IF art = 'L' THEN
        SELECT INTO erg *, sta_long
          FROM ergebnis
          LEFT OUTER JOIN status
            ON sta_status = erg_status
         WHERE erg_vid = vid
           AND erg_wid = wid
           AND erg_snr = snr
           AND erg_eid = 0;

        IF erg.erg_wert IS NULL THEN
            RETURN erg.sta_long;
        ELSE
            ret := formatzeit(erg.erg_wert, erg.erg_hand);
            IF erg.erg_wind IS NOT NULL THEN
                ret := ret || ' (' || formatwind(erg.erg_wind) || 'm/s)';
            END IF;
            RETURN ret;
        END IF;
    ELSIF art = 'W' THEN
      ret := '';
      FOR erg IN
          SELECT erg_wert, sta_long, erg_wind
            FROM ergebnis
            LEFT OUTER JOIN status
              ON sta_status = erg_status
           WHERE erg_vid = vid
             AND erg_wid = wid
             AND erg_snr = snr
           ORDER BY erg_eid
      LOOP
          IF ret <> '' THEN
              ret := ret || ' / ';
          END IF;
          IF erg.erg_wert IS NULL THEN
              ret := ret || erg.sta_long;
          ELSE
              ret := ret || formatdouble2f(erg.erg_wert) || 'm';
              IF erg.erg_wind IS NOT NULL THEN
                  ret := ret || ' (' || formatwind(erg.erg_wind) || 'm/s)';
              END IF;
          END IF;
      END LOOP;
      RETURN ret;
    ELSE
        RETURN NULL;
    END IF;
END;$_$;


ALTER FUNCTION public.ergebnis_long(character, integer, integer, integer) OWNER TO postgres;

--
-- Name: ergebnis_short(character, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ergebnis_short(character, integer, integer, integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    art ALIAS FOR $1;
    vid ALIAS FOR $2;
    wid ALIAS FOR $3;
    snr ALIAS FOR $4;
    erg RECORD;
    ret ergebnis.erg_wert%type;
BEGIN
    IF art = 'L' THEN
        SELECT INTO erg *
          FROM ergebnis
         WHERE erg_vid = vid
           AND erg_wid = wid
           AND erg_snr = snr
           AND erg_eid = 0;

        IF erg.erg_wert IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN formatzeit(erg.erg_wert, erg.erg_hand);
        END IF;
    ELSIF art = 'W' THEN
        SELECT INTO ret
           MAX(erg_wert)
          FROM ergebnis
         WHERE erg_vid = vid
           AND erg_wid = wid
           AND erg_snr = snr;

        IF ret IS NULL THEN
            RETURN NULL;
        ELSE
            RETURN formatdouble2f(ret) || 'm';
        END IF;
    ELSE
        RETURN NULL;
    END IF;
END;$_$;


ALTER FUNCTION public.ergebnis_short(character, integer, integer, integer) OWNER TO postgres;

--
-- Name: ergebnis_sort(character, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ergebnis_sort(character, integer, integer, integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    art ALIAS FOR $1;
    vid ALIAS FOR $2;
    wid ALIAS FOR $3;
    snr ALIAS FOR $4;
    erg RECORD;
    ret TEXT;
BEGIN
    IF art = 'L' THEN
        SELECT INTO erg *
          FROM ergebnis
         WHERE erg_vid = vid
           AND erg_wid = wid
           AND erg_snr = snr
           AND erg_eid = 0;

        IF erg.erg_wert IS NULL THEN
            RETURN '~';
        ELSE
            RETURN LPAD(CAST(ROUND(erg.erg_wert * 1000) AS text), 12, '0');
        END IF;
    ELSIF art = 'W' THEN
        ret := '';
        FOR erg IN
            SELECT erg_wert
              FROM ergebnis
             WHERE erg_vid = vid
               AND erg_wid = wid
               AND erg_snr = snr
               AND erg_wert IS NOT NULL
             ORDER BY erg_wert DESC
        LOOP
            ret := ret || LPAD(CAST(ROUND((10000 - erg.erg_wert) * 100000) AS text), 10, '0');
        END LOOP;
        IF ret = '' THEN
            RETURN 'X';
        ELSE
            RETURN ret;
        END IF;
    ELSE
        RETURN NULL;
    END IF;
END;$_$;


ALTER FUNCTION public.ergebnis_sort(character, integer, integer, integer) OWNER TO postgres;

--
-- Name: ergebnis_value(character, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ergebnis_value(character, integer, integer, integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    art ALIAS FOR $1;
    vid ALIAS FOR $2;
    wid ALIAS FOR $3;
    snr ALIAS FOR $4;
    erg ergebnis.erg_wert%type;
    ret ergebnis.erg_wert%type;
BEGIN
    IF art = 'L' THEN
        SELECT INTO ret
               MIN(erg_wert)
          FROM ergebnis
         WHERE erg_vid = vid
           AND erg_wid = wid
           AND erg_snr = snr;
        RETURN ret;
    ELSIF art = 'W' THEN
        SELECT INTO ret
               MAX(erg_wert)
          FROM ergebnis
         WHERE erg_vid = vid
           AND erg_wid = wid
           AND erg_snr = snr;
        RETURN ret;
    ELSE
        RETURN NULL;
    END IF;
END;$_$;


ALTER FUNCTION public.ergebnis_value(character, integer, integer, integer) OWNER TO postgres;

--
-- Name: ergebnis_wind(character, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: tommi
--

CREATE FUNCTION ergebnis_wind(character, integer, integer, integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
    art ALIAS FOR $1;
    vid ALIAS FOR $2;
    wid ALIAS FOR $3;
    snr ALIAS FOR $4;
    erg RECORD;
    ret ergebnis.erg_wind%type;
BEGIN
    IF art = 'L' THEN
        SELECT INTO ret erg_wind
          FROM ergebnis
         WHERE erg_vid = vid
           AND erg_wid = wid
           AND erg_snr = snr
           AND erg_eid = 0;

        RETURN ret;
    ELSIF art = 'W' THEN
        SELECT INTO ret
           MIN(erg_wind)
           FROM ergebnis
         WHERE erg_vid = vid
           AND erg_wid = wid
           AND erg_snr = snr
           AND erg_wert = (
                SELECT MAX(erg_wert)
                  FROM ergebnis
                 WHERE erg_vid = vid
                   AND erg_wid = wid
                   AND erg_snr = snr);

        return ret;
    ELSE
        RETURN NULL;
    END IF;
END;$_$;


ALTER FUNCTION public.ergebnis_wind(character, integer, integer, integer) OWNER TO tommi;

--
-- Name: formatdouble1f(double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION formatdouble1f(double precision) RETURNS text
    LANGUAGE plperl
    AS $_X$
  return sprintf('%.1f', $_[0]);
$_X$;


ALTER FUNCTION public.formatdouble1f(double precision) OWNER TO postgres;

--
-- Name: formatdouble2f(double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION formatdouble2f(double precision) RETURNS text
    LANGUAGE plperl
    AS $_X$
  return sprintf('%.2f', $_[0]);
$_X$;


ALTER FUNCTION public.formatdouble2f(double precision) OWNER TO postgres;

--
-- Name: formatwind(double precision); Type: FUNCTION; Schema: public; Owner: tommi
--

CREATE FUNCTION formatwind(double precision) RETURNS text
    LANGUAGE plperl
    AS $_X$
  return sprintf('%+.1f', $_[0]);
$_X$;


ALTER FUNCTION public.formatwind(double precision) OWNER TO tommi;

--
-- Name: formatzeit(double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION formatzeit(double precision) RETURNS text
    LANGUAGE plperl
    AS $_$
  my $z = shift;
  my $zz = $z;
  my $std = int($z / 3600);
  $z %= 3600;
  my $min = int($z / 60);
  my $sec = int($z % 60);
  my $zsec = int($zz * 100 % 100 + .5);

  return $std ? sprintf("%d:%02d:%02d,%02d Std", $std, $min, $sec, $zsec)
       : $min ? sprintf("%d:%02d,%02d min", $min, $sec, $zsec)
       :        sprintf("%d,%02d sec", $sec, $zsec);

$_$;


ALTER FUNCTION public.formatzeit(double precision) OWNER TO postgres;

--
-- Name: formatzeit(double precision, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION formatzeit(double precision, boolean) RETURNS text
    LANGUAGE plperl
    AS $_$
  my $z = shift;
  my $hand = shift eq 't';
  $z += $hand ? .999 : .001;
  my $zz = $z;
  my $std = int($z / 3600);
  $z %= 3600;
  my $min = int($z / 60);
  my $sec = int($z % 60);
  my $zsec = $hand ? int($zz * 10 % 10) : int($zz * 100 % 100);

  my $zd = $hand ? 0 : 2;

  if ($std == 0 && $min == 1 && $sec < 40)
  {
    $min = 0;
    $sec += 60;
  }

  if ($hand)
  {
    return $std ? sprintf("%d:%02d:%02d Std", $std, $min, $sec)
         : $min ? sprintf("%d:%02d min", $min, $sec)
         :        sprintf("%d,%0${zd}d sec", $sec, $zsec);
  }
  else
  {
    return $std ? sprintf("%d:%02d:%02d,%0${zd}d Std", $std, $min, $sec, $zsec)
         : $min ? sprintf("%d:%02d,%0${zd}d min", $min, $sec, $zsec)
         :        sprintf("%d,%0${zd}d sec", $sec, $zsec);
  }

$_$;


ALTER FUNCTION public.formatzeit(double precision, boolean) OWNER TO postgres;

--
-- Name: personak(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION personak(integer, integer) RETURNS character
    LANGUAGE plpgsql
    AS $_$
DECLARE
    vid ALIAS FOR $1;
    pid ALIAS FOR $2;
    ak klasse.kls_ak%type;
BEGIN
    SELECT INTO ak
           pak_ak
      FROM personak
      JOIN klasse
        ON kls_ak = pak_ak
     WHERE pak_pid = pid
       AND pak_vid = vid
     ORDER BY kls_prioritaet
     LIMIT 1;

    RETURN ak;
END;$_$;


ALTER FUNCTION public.personak(integer, integer) OWNER TO postgres;

--
-- Name: personak(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION personak(integer, integer, integer) RETURNS character
    LANGUAGE plpgsql
    AS $_$
DECLARE
    vid ALIAS FOR $1;
    wid ALIAS FOR $2;
    pid ALIAS FOR $3;
    ak klasse.kls_ak%type;
    prioritaet klasse.kls_prioritaet%type;
BEGIN
    SELECT INTO ak, prioritaet
           kls_ak, kls_prioritaet
      FROM meldung
      JOIN wertungak
        ON wea_vid = mel_vid
       AND wea_wid = mel_wid
       AND wea_rid = mel_rid
      JOIN klasse
        ON kls_ak = wea_ak
      JOIN person
        ON per_pid = mel_pid
       AND per_geschlecht = kls_geschlecht
     WHERE mel_vid = vid
       AND mel_wid = wid
       AND mel_pid = pid
    UNION
    SELECT kls_ak, kls_prioritaet
      FROM mehrkampfmeldung
      JOIN mehrkampfwertung
        ON mew_vid = mem_vid
       AND mew_hid = mem_hid
      JOIN mehrkampfak
        ON mea_vid = mem_vid
       AND mea_hid = mem_hid
      JOIN klasse
        ON kls_ak = mea_ak
      JOIN person
        ON per_pid = mem_pid
       AND per_geschlecht = kls_geschlecht
     WHERE mem_pid = pid
       AND mem_vid = vid
       AND mew_wid = wid
     ORDER BY kls_prioritaet
     LIMIT 1;

    RETURN ak;
END;$_$;


ALTER FUNCTION public.personak(integer, integer, integer) OWNER TO postgres;

--
-- Name: personak_long(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: tommi
--

CREATE FUNCTION personak_long(integer, integer, integer) RETURNS character
    LANGUAGE plpgsql
    AS $_$
DECLARE
    vid ALIAS FOR $1;
    wid ALIAS FOR $2;
    pid ALIAS FOR $3;
    ak klasse.kls_bezeichnung%type;
    prioritaet klasse.kls_prioritaet%type;
BEGIN
    SELECT INTO ak, prioritaet
           kls_bezeichnung, kls_prioritaet
      FROM meldung
      JOIN wertungak
        ON wea_vid = mel_vid
       AND wea_wid = mel_wid
       AND wea_rid = mel_rid
      JOIN klasse
        ON kls_ak = wea_ak
     WHERE mel_vid = vid
       AND mel_wid = wid
       AND mel_pid = pid
    UNION
    SELECT kls_bezeichnung, kls_prioritaet
      FROM mehrkampfmeldung
      JOIN mehrkampfwertung
        ON mew_vid = mem_vid
       AND mew_hid = mem_hid
      JOIN mehrkampfak
        ON mea_vid = mem_vid
       AND mea_hid = mem_hid
      JOIN klasse
        ON kls_ak = mea_ak
     WHERE mem_pid = pid
       AND mem_vid = vid
       AND mew_wid = wid
     ORDER BY kls_prioritaet DESC
     LIMIT 1;

    RETURN ak;
END;$_$;


ALTER FUNCTION public.personak_long(integer, integer, integer) OWNER TO tommi;

--
-- Name: personakh(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION personakh(integer, integer, integer) RETURNS character
    LANGUAGE plpgsql
    AS $_$
DECLARE
    vid ALIAS FOR $1;
    hid ALIAS FOR $2;
    pid ALIAS FOR $3;
    ak klasse.kls_ak%type;
    prioritaet klasse.kls_prioritaet%type;
BEGIN
    SELECT INTO ak, prioritaet
           kls_ak, kls_prioritaet
      FROM mehrkampfmeldung
      JOIN mehrkampfak
        ON mea_vid = mem_vid
       AND mea_hid = mem_hid
      JOIN klasse
        ON kls_ak = mea_ak
     WHERE mem_pid = pid
       AND mem_vid = vid
       AND mem_hid = hid
     ORDER BY kls_prioritaet DESC
     LIMIT 1;

    RETURN ak;
END;$_$;


ALTER FUNCTION public.personakh(integer, integer, integer) OWNER TO postgres;

--
-- Name: plperl_call_handler(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION plperl_call_handler() RETURNS language_handler
    LANGUAGE c
    AS '$libdir/plperl', 'plperl_call_handler';


ALTER FUNCTION public.plperl_call_handler() OWNER TO postgres;

--
-- Name: plpgsql_call_handler(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION plpgsql_call_handler() RETURNS language_handler
    LANGUAGE c
    AS '$libdir/plpgsql', 'plpgsql_call_handler';


ALTER FUNCTION public.plpgsql_call_handler() OWNER TO postgres;

--
-- Name: wertungak(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION wertungak(integer, integer, integer) RETURNS character
    LANGUAGE plpgsql
    AS $_$
DECLARE
    vid ALIAS FOR $1;
    wid ALIAS FOR $2;
    rid ALIAS FOR $3;
    ak klasse.kls_ak%type;
BEGIN
    SELECT INTO ak
           kls_ak
      FROM klasse
      JOIN wertungak
        ON wea_ak = kls_ak
     WHERE wea_vid = vid
       AND wea_wid = wid
       AND wea_rid = rid
     ORDER BY kls_prioritaet
     LIMIT 1;

    RETURN ak;
END;$_$;


ALTER FUNCTION public.wertungak(integer, integer, integer) OWNER TO postgres;

--
-- Name: wertungprio(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: tommi
--

CREATE FUNCTION wertungprio(integer, integer, integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    vid ALIAS FOR $1;
    wid ALIAS FOR $2;
    rid ALIAS FOR $3;
    w wid%type;
BEGIN
    SELECT INTO w
           wer_abhaengig
      FROM wertung
     WHERE wer_vid = vid
       AND wer_wid = wid
       AND wer_rid = rid;

    IF w IS NULL THEN
        RETURN 0;
    ELSE
      SELECT INTO w
             wer_abhaengig
        FROM wertung
       WHERE wer_vid = vid
         AND wer_wid = wid
         AND wer_abhaengig = rid;

      IF w IS NULL THEN
        RETURN 2;
      ELSE
        RETURN 1;
      END IF;
    END IF;
END;$_$;


ALTER FUNCTION public.wertungprio(integer, integer, integer) OWNER TO tommi;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: bahnverteilung; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE bahnverteilung (
    bav_vid integer NOT NULL,
    bav_wid integer NOT NULL,
    bav_pid integer NOT NULL,
    bav_lauf integer NOT NULL,
    bav_bahn integer NOT NULL
);


ALTER TABLE public.bahnverteilung OWNER TO postgres;

--
-- Name: ergebnis; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE ergebnis (
    erg_vid integer NOT NULL,
    erg_wid integer NOT NULL,
    erg_snr integer NOT NULL,
    erg_eid integer DEFAULT 0 NOT NULL,
    erg_wert double precision,
    erg_status character(1) DEFAULT ' '::bpchar NOT NULL,
    erg_erfolg boolean DEFAULT true NOT NULL,
    erg_wind double precision,
    erg_hand boolean DEFAULT true NOT NULL
);


ALTER TABLE public.ergebnis OWNER TO postgres;

--
-- Name: wettkampf; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wettkampf (
    wet_vid integer NOT NULL,
    wet_wid integer NOT NULL,
    wet_name text NOT NULL,
    wet_richtwert double precision,
    wet_art character(1) DEFAULT 'L'::bpchar NOT NULL,
    wet_sta_von integer,
    wet_sta_bis integer,
    wet_startzeit time without time zone
);


ALTER TABLE public.wettkampf OWNER TO postgres;

--
-- Name: ergebnisv; Type: VIEW; Schema: public; Owner: tommi
--

CREATE VIEW ergebnisv AS
 SELECT ergebnis.erg_vid,
    ergebnis.erg_wid,
    ergebnis.erg_snr,
    ergebnis.erg_status,
    wettkampf.wet_art AS erg_art,
    ergebnis.erg_hand,
    ergebnis_wind(wettkampf.wet_art, ergebnis.erg_vid, ergebnis.erg_wid, ergebnis.erg_snr) AS erg_wind,
    ergebnis_value(wettkampf.wet_art, ergebnis.erg_vid, ergebnis.erg_wid, ergebnis.erg_snr) AS erg_value,
    ergebnis_short(wettkampf.wet_art, ergebnis.erg_vid, ergebnis.erg_wid, ergebnis.erg_snr) AS erg_wert,
    ergebnis_long(wettkampf.wet_art, ergebnis.erg_vid, ergebnis.erg_wid, ergebnis.erg_snr) AS erg_long,
    ergebnis_sort(wettkampf.wet_art, ergebnis.erg_vid, ergebnis.erg_wid, ergebnis.erg_snr) AS erg_sort
   FROM (ergebnis
     JOIN wettkampf ON (((wettkampf.wet_vid = ergebnis.erg_vid) AND (wettkampf.wet_wid = ergebnis.erg_wid))))
  WHERE (ergebnis.erg_eid = 0);


ALTER TABLE public.ergebnisv OWNER TO tommi;

--
-- Name: klasse; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE klasse (
    kls_ak character(4) NOT NULL,
    kls_geschlecht character(1) NOT NULL,
    kls_alter_von integer NOT NULL,
    kls_alter_bis integer NOT NULL,
    kls_prioritaet integer NOT NULL,
    kls_bezeichnung text NOT NULL
);


ALTER TABLE public.klasse OWNER TO postgres;

--
-- Name: leistung; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE leistung (
    lei_pid integer NOT NULL,
    lei_vid integer NOT NULL,
    lei_wid integer NOT NULL,
    lei_wert double precision NOT NULL
);


ALTER TABLE public.leistung OWNER TO postgres;

--
-- Name: startnummer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE startnummer (
    sta_vid integer NOT NULL,
    sta_snr integer NOT NULL,
    sta_pid integer NOT NULL
);


ALTER TABLE public.startnummer OWNER TO postgres;

--
-- Name: leistungv; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW leistungv AS
 SELECT leistung.lei_pid,
    leistung.lei_vid,
    leistung.lei_wid,
    leistung.lei_wert,
    ergebnis_short(wettkampf.wet_art, leistung.lei_vid, leistung.lei_wid, startnummer.sta_snr) AS lei_short,
    ergebnis_sort(wettkampf.wet_art, leistung.lei_vid, leistung.lei_wid, startnummer.sta_snr) AS lei_sort
   FROM ((leistung
     JOIN startnummer ON (((startnummer.sta_pid = leistung.lei_pid) AND (startnummer.sta_vid = leistung.lei_vid))))
     JOIN wettkampf ON (((wettkampf.wet_vid = leistung.lei_vid) AND (wettkampf.wet_wid = leistung.lei_wid))));


ALTER TABLE public.leistungv OWNER TO postgres;

--
-- Name: liste; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE liste (
    lis_vid integer NOT NULL,
    lis_lid integer NOT NULL,
    lis_name text NOT NULL
);


ALTER TABLE public.liste OWNER TO postgres;

--
-- Name: listew; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE listew (
    liw_vid integer NOT NULL,
    liw_lid integer NOT NULL,
    liw_order integer NOT NULL,
    liw_wid integer NOT NULL,
    liw_rid integer,
    liw_gid integer,
    liw_mid integer,
    liw_hid integer,
    liw_sid integer,
    liw_tid integer
);


ALTER TABLE public.listew OWNER TO postgres;

--
-- Name: manwertung; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE manwertung (
    man_vid integer NOT NULL,
    man_wid integer NOT NULL,
    man_mid integer NOT NULL,
    man_name text NOT NULL,
    man_anzahl integer NOT NULL,
    man_typ character(1) NOT NULL,
    man_urkunde text,
    CONSTRAINT manwertung_man_typ CHECK (((man_typ = 'Z'::bpchar) OR (man_typ = 'P'::bpchar)))
);


ALTER TABLE public.manwertung OWNER TO postgres;

--
-- Name: manwertungw; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE manwertungw (
    maw_vid integer NOT NULL,
    maw_wid integer NOT NULL,
    maw_mid integer NOT NULL,
    maw_rid integer NOT NULL
);


ALTER TABLE public.manwertungw OWNER TO postgres;

--
-- Name: mehrkampf; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mehrkampf (
    mer_vid integer NOT NULL,
    mer_hid integer NOT NULL,
    mer_name text NOT NULL,
    mer_urkunde text,
    mer_abhaengig integer
);


ALTER TABLE public.mehrkampf OWNER TO postgres;

--
-- Name: mehrkampfak; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mehrkampfak (
    mea_vid integer NOT NULL,
    mea_hid integer NOT NULL,
    mea_ak character(4) NOT NULL
);


ALTER TABLE public.mehrkampfak OWNER TO postgres;

--
-- Name: mehrkampfgruppe; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mehrkampfgruppe (
    mgr_vid integer NOT NULL,
    mgr_mgid integer NOT NULL,
    mgr_name text NOT NULL,
    mgr_wertungen integer,
    mgr_urkunde text
);


ALTER TABLE public.mehrkampfgruppe OWNER TO postgres;

--
-- Name: mehrkampfgruppew; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mehrkampfgruppew (
    mgw_vid integer NOT NULL,
    mgw_mgid integer NOT NULL,
    mgw_hid integer NOT NULL
);


ALTER TABLE public.mehrkampfgruppew OWNER TO postgres;

--
-- Name: mehrkampfmeldung; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mehrkampfmeldung (
    mem_pid integer NOT NULL,
    mem_vid integer NOT NULL,
    mem_hid integer NOT NULL
);


ALTER TABLE public.mehrkampfmeldung OWNER TO postgres;

--
-- Name: mehrkampfwertung; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE mehrkampfwertung (
    mew_vid integer NOT NULL,
    mew_wid integer NOT NULL,
    mew_hid integer NOT NULL,
    mew_formel text
);


ALTER TABLE public.mehrkampfwertung OWNER TO postgres;

--
-- Name: meldung; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE meldung (
    mel_pid integer NOT NULL,
    mel_vid integer NOT NULL,
    mel_wid integer NOT NULL,
    mel_rid integer NOT NULL
);


ALTER TABLE public.meldung OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE person (
    per_pid integer NOT NULL,
    per_nachname text NOT NULL,
    per_vorname text NOT NULL,
    per_verein text,
    per_geschlecht character(1) NOT NULL,
    per_jahrgang integer NOT NULL,
    per_strasse text,
    per_plz text,
    per_ort text,
    per_land text,
    per_nationalitaet text
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: veranstaltung; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE veranstaltung (
    van_vid integer NOT NULL,
    van_datum date NOT NULL,
    van_datum_bis date,
    van_name text NOT NULL,
    van_ort text NOT NULL,
    van_logo text
);


ALTER TABLE public.veranstaltung OWNER TO postgres;

--
-- Name: personak; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW personak AS
 SELECT veranstaltung.van_vid AS pak_vid,
    person.per_pid AS pak_pid,
    person.per_nachname AS pak_nachname,
    person.per_vorname AS pak_vorname,
    person.per_verein AS pak_verein,
    person.per_geschlecht AS pak_geschlecht,
    person.per_jahrgang AS pak_jahrgang,
    person.per_strasse AS pak_strasse,
    person.per_plz AS pak_plz,
    person.per_ort AS pak_ort,
    person.per_land AS pak_land,
    person.per_nationalitaet AS pak_nationalitaet,
    (date_part('year'::text, veranstaltung.van_datum) - (person.per_jahrgang)::double precision) AS pak_alter,
    klasse.kls_ak AS pak_ak,
    klasse.kls_bezeichnung AS pak_akbezeichnung
   FROM veranstaltung,
    person,
    klasse
  WHERE ((person.per_geschlecht = klasse.kls_geschlecht) AND (((date_part('year'::text, veranstaltung.van_datum) - (person.per_jahrgang)::double precision) >= (klasse.kls_alter_von)::double precision) AND ((date_part('year'::text, veranstaltung.van_datum) - (person.per_jahrgang)::double precision) <= (klasse.kls_alter_bis)::double precision)));


ALTER TABLE public.personak OWNER TO postgres;

--
-- Name: personv; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW personv AS
 SELECT veranstaltung.van_vid AS per_vid,
    person.per_pid,
    person.per_nachname,
    person.per_vorname,
    person.per_verein,
    person.per_geschlecht,
    person.per_jahrgang,
    person.per_strasse,
    person.per_plz,
    person.per_ort,
    person.per_land,
    person.per_nationalitaet,
    (date_part('year'::text, veranstaltung.van_datum) - (person.per_jahrgang)::double precision) AS per_alter,
    klasse.kls_ak AS per_ak
   FROM veranstaltung,
    person,
    klasse
  WHERE ((person.per_geschlecht = klasse.kls_geschlecht) AND (((date_part('year'::text, veranstaltung.van_datum) - (person.per_jahrgang)::double precision) >= (klasse.kls_alter_von)::double precision) AND ((date_part('year'::text, veranstaltung.van_datum) - (person.per_jahrgang)::double precision) <= (klasse.kls_alter_bis)::double precision)));


ALTER TABLE public.personv OWNER TO postgres;

--
-- Name: pga_diagrams; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE pga_diagrams (
    diagramname character varying(64) NOT NULL,
    diagramtables text,
    diagramlinks text
);


ALTER TABLE public.pga_diagrams OWNER TO tommi;

--
-- Name: pga_forms; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE pga_forms (
    formname character varying(64) NOT NULL,
    formsource text
);


ALTER TABLE public.pga_forms OWNER TO tommi;

--
-- Name: pga_graphs; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE pga_graphs (
    graphname character varying(64) NOT NULL,
    graphsource text,
    graphcode text
);


ALTER TABLE public.pga_graphs OWNER TO tommi;

--
-- Name: pga_layout; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE pga_layout (
    tablename character varying(64) NOT NULL,
    nrcols smallint,
    colnames text,
    colwidth text
);


ALTER TABLE public.pga_layout OWNER TO tommi;

--
-- Name: pga_queries; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE pga_queries (
    queryname character varying(64) NOT NULL,
    querytype character(1),
    querycommand text,
    querytables text,
    querylinks text,
    queryresults text,
    querycomments text
);


ALTER TABLE public.pga_queries OWNER TO tommi;

--
-- Name: pga_reports; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE pga_reports (
    reportname character varying(64) NOT NULL,
    reportsource text,
    reportbody text,
    reportprocs text,
    reportoptions text
);


ALTER TABLE public.pga_reports OWNER TO tommi;

--
-- Name: pga_scripts; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE pga_scripts (
    scriptname character varying(64) NOT NULL,
    scriptsource text
);


ALTER TABLE public.pga_scripts OWNER TO tommi;

SET default_with_oids = false;

--
-- Name: stamannschaft; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE stamannschaft (
    stm_vid integer NOT NULL,
    stm_smid integer NOT NULL,
    stm_verein text NOT NULL,
    stm_zusatz text NOT NULL,
    stm_sid integer,
    stm_tid integer,
    stm_lauf integer,
    stm_bahn integer,
    stm_ergebnis double precision,
    stm_status character(1) DEFAULT ' '::bpchar NOT NULL
);


ALTER TABLE public.stamannschaft OWNER TO tommi;

--
-- Name: stamannschaftp; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE stamannschaftp (
    stp_vid integer NOT NULL,
    stp_smid integer NOT NULL,
    stp_pid integer NOT NULL,
    stp_order integer NOT NULL
);


ALTER TABLE public.stamannschaftp OWNER TO tommi;

SET default_with_oids = true;

--
-- Name: status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE status (
    sta_status character(1) NOT NULL,
    sta_long text
);


ALTER TABLE public.status OWNER TO postgres;

SET default_with_oids = false;

--
-- Name: stawertung; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE stawertung (
    str_vid integer NOT NULL,
    str_sid integer NOT NULL,
    str_tid integer NOT NULL,
    str_name text NOT NULL,
    str_urkunde text,
    str_ak character(4) NOT NULL
);


ALTER TABLE public.stawertung OWNER TO tommi;

--
-- Name: stawettkampf; Type: TABLE; Schema: public; Owner: tommi; Tablespace: 
--

CREATE TABLE stawettkampf (
    sta_vid integer NOT NULL,
    sta_sid integer NOT NULL,
    sta_name text NOT NULL,
    sta_anz integer NOT NULL
);


ALTER TABLE public.stawettkampf OWNER TO tommi;

SET default_with_oids = true;

--
-- Name: urkunde; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE urkunde (
    urk_vid integer NOT NULL,
    urk_pid integer NOT NULL
);


ALTER TABLE public.urkunde OWNER TO postgres;

--
-- Name: verein; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE verein (
    ver_name text NOT NULL,
    ver_verein boolean DEFAULT true NOT NULL
);


ALTER TABLE public.verein OWNER TO postgres;

--
-- Name: wertung; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wertung (
    wer_vid integer NOT NULL,
    wer_wid integer NOT NULL,
    wer_rid integer NOT NULL,
    wer_name text NOT NULL,
    wer_abhaengig integer,
    wer_urkunde text,
    wer_preis numeric(8,2)
);


ALTER TABLE public.wertung OWNER TO postgres;

--
-- Name: wertungak; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wertungak (
    wea_vid integer NOT NULL,
    wea_wid integer NOT NULL,
    wea_rid integer NOT NULL,
    wea_ak character(4) NOT NULL
);


ALTER TABLE public.wertungak OWNER TO postgres;

--
-- Name: wertungakv2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW wertungakv2 AS
 SELECT w1.wea_vid AS wav_vid,
    w1.wea_wid AS wav_wid,
    w1.wea_rid AS wav_rid,
    k1.kls_ak AS wav_ak,
    k1.kls_geschlecht AS wav_geschlecht
   FROM (((wertungak w1
     JOIN klasse k1 ON ((k1.kls_ak = w1.wea_ak)))
     JOIN wertungak w2 ON ((((w2.wea_vid = w1.wea_vid) AND (w2.wea_wid = w1.wea_wid)) AND (w2.wea_rid = w1.wea_rid))))
     JOIN klasse k2 ON ((k2.kls_ak = w2.wea_ak)))
  GROUP BY w1.wea_vid, w1.wea_wid, w1.wea_rid, k1.kls_ak, k1.kls_geschlecht, k1.kls_prioritaet
 HAVING (k1.kls_prioritaet = min(k2.kls_prioritaet));


ALTER TABLE public.wertungakv2 OWNER TO postgres;

--
-- Name: wgruppe; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wgruppe (
    wgr_vid integer NOT NULL,
    wgr_wid integer NOT NULL,
    wgr_gid integer NOT NULL,
    wgr_name text NOT NULL
);


ALTER TABLE public.wgruppe OWNER TO postgres;

--
-- Name: wgruppewer; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wgruppewer (
    wgw_vid integer NOT NULL,
    wgw_wid integer NOT NULL,
    wgw_gid integer NOT NULL,
    wgw_rid integer NOT NULL
);


ALTER TABLE public.wgruppewer OWNER TO postgres;

--
-- Name: bahnverteilung_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY bahnverteilung
    ADD CONSTRAINT bahnverteilung_pk PRIMARY KEY (bav_vid, bav_wid, bav_pid, bav_lauf);


--
-- Name: ergebnis_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ergebnis
    ADD CONSTRAINT ergebnis_pk PRIMARY KEY (erg_vid, erg_wid, erg_snr, erg_eid);


--
-- Name: klasse_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY klasse
    ADD CONSTRAINT klasse_pk PRIMARY KEY (kls_ak);


--
-- Name: leistung_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY leistung
    ADD CONSTRAINT leistung_pk PRIMARY KEY (lei_pid, lei_vid, lei_wid);


--
-- Name: liste_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY liste
    ADD CONSTRAINT liste_pk PRIMARY KEY (lis_vid, lis_lid);


--
-- Name: listew_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY listew
    ADD CONSTRAINT listew_pk PRIMARY KEY (liw_vid, liw_lid, liw_order);


--
-- Name: manwertung_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY manwertung
    ADD CONSTRAINT manwertung_pk PRIMARY KEY (man_vid, man_wid, man_mid);


--
-- Name: manwertungw_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY manwertungw
    ADD CONSTRAINT manwertungw_pk PRIMARY KEY (maw_vid, maw_wid, maw_mid, maw_rid);


--
-- Name: mehrkampf_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mehrkampf
    ADD CONSTRAINT mehrkampf_pk PRIMARY KEY (mer_vid, mer_hid);


--
-- Name: mehrkampfak_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mehrkampfak
    ADD CONSTRAINT mehrkampfak_pk PRIMARY KEY (mea_vid, mea_hid, mea_ak);


--
-- Name: mehrkampfgruppe_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mehrkampfgruppe
    ADD CONSTRAINT mehrkampfgruppe_pk PRIMARY KEY (mgr_vid, mgr_mgid);


--
-- Name: mehrkampfgruppew_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mehrkampfgruppew
    ADD CONSTRAINT mehrkampfgruppew_pk PRIMARY KEY (mgw_vid, mgw_mgid, mgw_hid);


--
-- Name: mehrkampfmeldung_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mehrkampfmeldung
    ADD CONSTRAINT mehrkampfmeldung_pk PRIMARY KEY (mem_pid, mem_vid, mem_hid);


--
-- Name: mehrkampfwertung_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mehrkampfwertung
    ADD CONSTRAINT mehrkampfwertung_pk PRIMARY KEY (mew_vid, mew_wid, mew_hid);


--
-- Name: meldung_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY meldung
    ADD CONSTRAINT meldung_pk PRIMARY KEY (mel_pid, mel_vid, mel_wid, mel_rid);


--
-- Name: person_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_pk PRIMARY KEY (per_pid);


--
-- Name: pga_diagrams_pkey; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY pga_diagrams
    ADD CONSTRAINT pga_diagrams_pkey PRIMARY KEY (diagramname);


--
-- Name: pga_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY pga_forms
    ADD CONSTRAINT pga_forms_pkey PRIMARY KEY (formname);


--
-- Name: pga_graphs_pkey; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY pga_graphs
    ADD CONSTRAINT pga_graphs_pkey PRIMARY KEY (graphname);


--
-- Name: pga_layout_pkey; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY pga_layout
    ADD CONSTRAINT pga_layout_pkey PRIMARY KEY (tablename);


--
-- Name: pga_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY pga_queries
    ADD CONSTRAINT pga_queries_pkey PRIMARY KEY (queryname);


--
-- Name: pga_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY pga_reports
    ADD CONSTRAINT pga_reports_pkey PRIMARY KEY (reportname);


--
-- Name: pga_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY pga_scripts
    ADD CONSTRAINT pga_scripts_pkey PRIMARY KEY (scriptname);


--
-- Name: stamannschaft_pk; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY stamannschaft
    ADD CONSTRAINT stamannschaft_pk PRIMARY KEY (stm_vid, stm_smid);


--
-- Name: stamannschaftp_pk; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY stamannschaftp
    ADD CONSTRAINT stamannschaftp_pk PRIMARY KEY (stp_vid, stp_smid, stp_pid);


--
-- Name: startnummer_ak; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY startnummer
    ADD CONSTRAINT startnummer_ak UNIQUE (sta_pid, sta_vid);


--
-- Name: startnummer_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY startnummer
    ADD CONSTRAINT startnummer_pk PRIMARY KEY (sta_vid, sta_snr);


--
-- Name: stawertung_pk; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY stawertung
    ADD CONSTRAINT stawertung_pk PRIMARY KEY (str_vid, str_sid, str_tid);


--
-- Name: stawettkampf_pk; Type: CONSTRAINT; Schema: public; Owner: tommi; Tablespace: 
--

ALTER TABLE ONLY stawettkampf
    ADD CONSTRAINT stawettkampf_pk PRIMARY KEY (sta_vid, sta_sid);


--
-- Name: urkunde_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY urkunde
    ADD CONSTRAINT urkunde_pk PRIMARY KEY (urk_vid, urk_pid);


--
-- Name: veranstaltung_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY veranstaltung
    ADD CONSTRAINT veranstaltung_pk PRIMARY KEY (van_vid);


--
-- Name: verein_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY verein
    ADD CONSTRAINT verein_pk PRIMARY KEY (ver_name);


--
-- Name: wertung_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wertung
    ADD CONSTRAINT wertung_pk PRIMARY KEY (wer_vid, wer_wid, wer_rid);


--
-- Name: wertungak_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wertungak
    ADD CONSTRAINT wertungak_pk PRIMARY KEY (wea_vid, wea_wid, wea_rid, wea_ak);


--
-- Name: wettkampf_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wettkampf
    ADD CONSTRAINT wettkampf_pk PRIMARY KEY (wet_vid, wet_wid);


--
-- Name: wgruppe_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wgruppe
    ADD CONSTRAINT wgruppe_pk PRIMARY KEY (wgr_vid, wgr_wid, wgr_gid);


--
-- Name: wgruppewer_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wgruppewer
    ADD CONSTRAINT wgruppewer_pk PRIMARY KEY (wgw_vid, wgw_wid, wgw_gid, wgw_rid);


--
-- Name: ergebnis_ix1; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX ergebnis_ix1 ON ergebnis USING btree (erg_status, erg_wert);


--
-- Name: meldung_ix1; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX meldung_ix1 ON meldung USING btree (mel_vid, mel_wid, mel_rid);


--
-- Name: person_ix1; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX person_ix1 ON person USING btree (per_verein);


--
-- Name: person_ix2; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX person_ix2 ON person USING btree (per_geschlecht, per_jahrgang);


--
-- Name: wertungak_ix1; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX wertungak_ix1 ON wertungak USING btree (wea_ak);


--
-- Name: bahnverteilung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bahnverteilung
    ADD CONSTRAINT bahnverteilung_fk1 FOREIGN KEY (bav_vid, bav_wid) REFERENCES wettkampf(wet_vid, wet_wid);


--
-- Name: bahnverteilung_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY bahnverteilung
    ADD CONSTRAINT bahnverteilung_fk2 FOREIGN KEY (bav_pid) REFERENCES person(per_pid);


--
-- Name: ergebnis_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ergebnis
    ADD CONSTRAINT ergebnis_fk1 FOREIGN KEY (erg_vid, erg_wid) REFERENCES wettkampf(wet_vid, wet_wid);


--
-- Name: ergebnis_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY ergebnis
    ADD CONSTRAINT ergebnis_fk2 FOREIGN KEY (erg_vid, erg_snr) REFERENCES startnummer(sta_vid, sta_snr);


--
-- Name: leistung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY leistung
    ADD CONSTRAINT leistung_fk1 FOREIGN KEY (lei_pid) REFERENCES person(per_pid);


--
-- Name: leistung_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY leistung
    ADD CONSTRAINT leistung_fk2 FOREIGN KEY (lei_vid, lei_wid) REFERENCES wettkampf(wet_vid, wet_wid);


--
-- Name: manwertung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY manwertung
    ADD CONSTRAINT manwertung_fk1 FOREIGN KEY (man_vid, man_wid) REFERENCES wettkampf(wet_vid, wet_wid);


--
-- Name: manwertungw_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY manwertungw
    ADD CONSTRAINT manwertungw_fk1 FOREIGN KEY (maw_vid, maw_wid, maw_mid) REFERENCES manwertung(man_vid, man_wid, man_mid);


--
-- Name: manwertungw_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY manwertungw
    ADD CONSTRAINT manwertungw_fk2 FOREIGN KEY (maw_vid, maw_wid, maw_rid) REFERENCES wertung(wer_vid, wer_wid, wer_rid);


--
-- Name: mehrkampf_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampf
    ADD CONSTRAINT mehrkampf_fk1 FOREIGN KEY (mer_vid) REFERENCES veranstaltung(van_vid);


--
-- Name: mehrkampfak_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampfak
    ADD CONSTRAINT mehrkampfak_fk1 FOREIGN KEY (mea_vid, mea_hid) REFERENCES mehrkampf(mer_vid, mer_hid);


--
-- Name: mehrkampfgruppe_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampfgruppe
    ADD CONSTRAINT mehrkampfgruppe_fk1 FOREIGN KEY (mgr_vid) REFERENCES veranstaltung(van_vid);


--
-- Name: mehrkampfgruppew_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampfgruppew
    ADD CONSTRAINT mehrkampfgruppew_fk1 FOREIGN KEY (mgw_vid, mgw_mgid) REFERENCES mehrkampfgruppe(mgr_vid, mgr_mgid);


--
-- Name: mehrkampfgruppew_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampfgruppew
    ADD CONSTRAINT mehrkampfgruppew_fk2 FOREIGN KEY (mgw_vid, mgw_hid) REFERENCES mehrkampf(mer_vid, mer_hid);


--
-- Name: mehrkampfmeldung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampfmeldung
    ADD CONSTRAINT mehrkampfmeldung_fk1 FOREIGN KEY (mem_pid) REFERENCES person(per_pid);


--
-- Name: mehrkampfwertung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampfwertung
    ADD CONSTRAINT mehrkampfwertung_fk1 FOREIGN KEY (mew_vid, mew_wid) REFERENCES wettkampf(wet_vid, wet_wid);


--
-- Name: mehrkampfwertung_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampfwertung
    ADD CONSTRAINT mehrkampfwertung_fk2 FOREIGN KEY (mew_vid, mew_hid) REFERENCES mehrkampf(mer_vid, mer_hid);


--
-- Name: mehrkampfwertung_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY mehrkampfak
    ADD CONSTRAINT mehrkampfwertung_fk2 FOREIGN KEY (mea_ak) REFERENCES klasse(kls_ak);


--
-- Name: meldung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY meldung
    ADD CONSTRAINT meldung_fk1 FOREIGN KEY (mel_pid) REFERENCES person(per_pid);


--
-- Name: meldung_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY meldung
    ADD CONSTRAINT meldung_fk2 FOREIGN KEY (mel_vid, mel_wid, mel_rid) REFERENCES wertung(wer_vid, wer_wid, wer_rid);


--
-- Name: stamannschaft_fk1; Type: FK CONSTRAINT; Schema: public; Owner: tommi
--

ALTER TABLE ONLY stamannschaft
    ADD CONSTRAINT stamannschaft_fk1 FOREIGN KEY (stm_vid) REFERENCES veranstaltung(van_vid);


--
-- Name: stamannschaft_fk2; Type: FK CONSTRAINT; Schema: public; Owner: tommi
--

ALTER TABLE ONLY stamannschaft
    ADD CONSTRAINT stamannschaft_fk2 FOREIGN KEY (stm_vid, stm_sid, stm_tid) REFERENCES stawertung(str_vid, str_sid, str_tid);


--
-- Name: stamannschaftp_fk1; Type: FK CONSTRAINT; Schema: public; Owner: tommi
--

ALTER TABLE ONLY stamannschaftp
    ADD CONSTRAINT stamannschaftp_fk1 FOREIGN KEY (stp_vid, stp_smid) REFERENCES stamannschaft(stm_vid, stm_smid);


--
-- Name: stamannschaftp_fk2; Type: FK CONSTRAINT; Schema: public; Owner: tommi
--

ALTER TABLE ONLY stamannschaftp
    ADD CONSTRAINT stamannschaftp_fk2 FOREIGN KEY (stp_pid) REFERENCES person(per_pid);


--
-- Name: startnummer_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY startnummer
    ADD CONSTRAINT startnummer_fk1 FOREIGN KEY (sta_pid) REFERENCES person(per_pid);


--
-- Name: startnummer_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY startnummer
    ADD CONSTRAINT startnummer_fk2 FOREIGN KEY (sta_vid) REFERENCES veranstaltung(van_vid);


--
-- Name: stawertung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: tommi
--

ALTER TABLE ONLY stawertung
    ADD CONSTRAINT stawertung_fk1 FOREIGN KEY (str_vid, str_sid) REFERENCES stawettkampf(sta_vid, sta_sid);


--
-- Name: stawertung_fk2; Type: FK CONSTRAINT; Schema: public; Owner: tommi
--

ALTER TABLE ONLY stawertung
    ADD CONSTRAINT stawertung_fk2 FOREIGN KEY (str_ak) REFERENCES klasse(kls_ak);


--
-- Name: urkunde_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY urkunde
    ADD CONSTRAINT urkunde_fk1 FOREIGN KEY (urk_vid) REFERENCES veranstaltung(van_vid);


--
-- Name: urkunde_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY urkunde
    ADD CONSTRAINT urkunde_fk2 FOREIGN KEY (urk_pid) REFERENCES person(per_pid);


--
-- Name: wertung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wertung
    ADD CONSTRAINT wertung_fk1 FOREIGN KEY (wer_vid, wer_wid) REFERENCES wettkampf(wet_vid, wet_wid);


--
-- Name: wertung_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wertungak
    ADD CONSTRAINT wertung_fk1 FOREIGN KEY (wea_vid, wea_wid, wea_rid) REFERENCES wertung(wer_vid, wer_wid, wer_rid);


--
-- Name: wertung_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wertungak
    ADD CONSTRAINT wertung_fk2 FOREIGN KEY (wea_ak) REFERENCES klasse(kls_ak);


--
-- Name: wettkampf_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wettkampf
    ADD CONSTRAINT wettkampf_fk1 FOREIGN KEY (wet_vid) REFERENCES veranstaltung(van_vid);


--
-- Name: wgruppe_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wgruppe
    ADD CONSTRAINT wgruppe_fk1 FOREIGN KEY (wgr_vid, wgr_wid) REFERENCES wettkampf(wet_vid, wet_wid);


--
-- Name: wgruppewer_fk1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wgruppewer
    ADD CONSTRAINT wgruppewer_fk1 FOREIGN KEY (wgw_vid, wgw_wid, wgw_gid) REFERENCES wgruppe(wgr_vid, wgr_wid, wgr_gid);


--
-- Name: wgruppewer_fk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wgruppewer
    ADD CONSTRAINT wgruppewer_fk2 FOREIGN KEY (wgw_vid, wgw_wid, wgw_rid) REFERENCES wertung(wer_vid, wer_wid, wer_rid);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: bahnverteilung; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE bahnverteilung FROM PUBLIC;
REVOKE ALL ON TABLE bahnverteilung FROM postgres;
GRANT ALL ON TABLE bahnverteilung TO postgres;
GRANT ALL ON TABLE bahnverteilung TO PUBLIC;


--
-- Name: ergebnis; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE ergebnis FROM PUBLIC;
REVOKE ALL ON TABLE ergebnis FROM postgres;
GRANT ALL ON TABLE ergebnis TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE ergebnis TO PUBLIC;


--
-- Name: wettkampf; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE wettkampf FROM PUBLIC;
REVOKE ALL ON TABLE wettkampf FROM postgres;
GRANT ALL ON TABLE wettkampf TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE wettkampf TO PUBLIC;


--
-- Name: ergebnisv; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE ergebnisv FROM PUBLIC;
REVOKE ALL ON TABLE ergebnisv FROM tommi;
GRANT ALL ON TABLE ergebnisv TO tommi;
GRANT SELECT ON TABLE ergebnisv TO PUBLIC;


--
-- Name: klasse; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE klasse FROM PUBLIC;
REVOKE ALL ON TABLE klasse FROM postgres;
GRANT ALL ON TABLE klasse TO postgres;
GRANT SELECT ON TABLE klasse TO PUBLIC;


--
-- Name: leistung; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE leistung FROM PUBLIC;
REVOKE ALL ON TABLE leistung FROM postgres;
GRANT ALL ON TABLE leistung TO postgres;
GRANT ALL ON TABLE leistung TO PUBLIC;


--
-- Name: startnummer; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE startnummer FROM PUBLIC;
REVOKE ALL ON TABLE startnummer FROM postgres;
GRANT ALL ON TABLE startnummer TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE startnummer TO PUBLIC;


--
-- Name: leistungv; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE leistungv FROM PUBLIC;
REVOKE ALL ON TABLE leistungv FROM postgres;
GRANT ALL ON TABLE leistungv TO postgres;
GRANT SELECT ON TABLE leistungv TO PUBLIC;


--
-- Name: liste; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE liste FROM PUBLIC;
REVOKE ALL ON TABLE liste FROM postgres;
GRANT ALL ON TABLE liste TO postgres;
GRANT ALL ON TABLE liste TO PUBLIC;


--
-- Name: listew; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE listew FROM PUBLIC;
REVOKE ALL ON TABLE listew FROM postgres;
GRANT ALL ON TABLE listew TO postgres;
GRANT ALL ON TABLE listew TO PUBLIC;


--
-- Name: manwertung; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE manwertung FROM PUBLIC;
REVOKE ALL ON TABLE manwertung FROM postgres;
GRANT ALL ON TABLE manwertung TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE manwertung TO PUBLIC;


--
-- Name: manwertungw; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE manwertungw FROM PUBLIC;
REVOKE ALL ON TABLE manwertungw FROM postgres;
GRANT ALL ON TABLE manwertungw TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE manwertungw TO PUBLIC;


--
-- Name: mehrkampf; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE mehrkampf FROM PUBLIC;
REVOKE ALL ON TABLE mehrkampf FROM postgres;
GRANT ALL ON TABLE mehrkampf TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE mehrkampf TO PUBLIC;


--
-- Name: mehrkampfak; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE mehrkampfak FROM PUBLIC;
REVOKE ALL ON TABLE mehrkampfak FROM postgres;
GRANT ALL ON TABLE mehrkampfak TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE mehrkampfak TO PUBLIC;


--
-- Name: mehrkampfgruppe; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE mehrkampfgruppe FROM PUBLIC;
REVOKE ALL ON TABLE mehrkampfgruppe FROM postgres;
GRANT ALL ON TABLE mehrkampfgruppe TO postgres;
GRANT ALL ON TABLE mehrkampfgruppe TO PUBLIC;


--
-- Name: mehrkampfgruppew; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE mehrkampfgruppew FROM PUBLIC;
REVOKE ALL ON TABLE mehrkampfgruppew FROM postgres;
GRANT ALL ON TABLE mehrkampfgruppew TO postgres;
GRANT ALL ON TABLE mehrkampfgruppew TO PUBLIC;


--
-- Name: mehrkampfmeldung; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE mehrkampfmeldung FROM PUBLIC;
REVOKE ALL ON TABLE mehrkampfmeldung FROM postgres;
GRANT ALL ON TABLE mehrkampfmeldung TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE mehrkampfmeldung TO PUBLIC;


--
-- Name: mehrkampfwertung; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE mehrkampfwertung FROM PUBLIC;
REVOKE ALL ON TABLE mehrkampfwertung FROM postgres;
GRANT ALL ON TABLE mehrkampfwertung TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE mehrkampfwertung TO PUBLIC;


--
-- Name: meldung; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE meldung FROM PUBLIC;
REVOKE ALL ON TABLE meldung FROM postgres;
GRANT ALL ON TABLE meldung TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE meldung TO PUBLIC;


--
-- Name: person; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE person FROM PUBLIC;
REVOKE ALL ON TABLE person FROM postgres;
GRANT ALL ON TABLE person TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE person TO PUBLIC;


--
-- Name: veranstaltung; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE veranstaltung FROM PUBLIC;
REVOKE ALL ON TABLE veranstaltung FROM postgres;
GRANT ALL ON TABLE veranstaltung TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE veranstaltung TO PUBLIC;


--
-- Name: personak; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE personak FROM PUBLIC;
REVOKE ALL ON TABLE personak FROM postgres;
GRANT ALL ON TABLE personak TO postgres;
GRANT SELECT ON TABLE personak TO PUBLIC;


--
-- Name: personv; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE personv FROM PUBLIC;
REVOKE ALL ON TABLE personv FROM postgres;
GRANT ALL ON TABLE personv TO postgres;
GRANT SELECT ON TABLE personv TO PUBLIC;


--
-- Name: pga_diagrams; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE pga_diagrams FROM PUBLIC;
REVOKE ALL ON TABLE pga_diagrams FROM tommi;
GRANT ALL ON TABLE pga_diagrams TO tommi;
GRANT ALL ON TABLE pga_diagrams TO PUBLIC;


--
-- Name: pga_forms; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE pga_forms FROM PUBLIC;
REVOKE ALL ON TABLE pga_forms FROM tommi;
GRANT ALL ON TABLE pga_forms TO tommi;
GRANT ALL ON TABLE pga_forms TO PUBLIC;


--
-- Name: pga_graphs; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE pga_graphs FROM PUBLIC;
REVOKE ALL ON TABLE pga_graphs FROM tommi;
GRANT ALL ON TABLE pga_graphs TO tommi;
GRANT ALL ON TABLE pga_graphs TO PUBLIC;


--
-- Name: pga_layout; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE pga_layout FROM PUBLIC;
REVOKE ALL ON TABLE pga_layout FROM tommi;
GRANT ALL ON TABLE pga_layout TO tommi;
GRANT ALL ON TABLE pga_layout TO PUBLIC;


--
-- Name: pga_queries; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE pga_queries FROM PUBLIC;
REVOKE ALL ON TABLE pga_queries FROM tommi;
GRANT ALL ON TABLE pga_queries TO tommi;
GRANT ALL ON TABLE pga_queries TO PUBLIC;


--
-- Name: pga_reports; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE pga_reports FROM PUBLIC;
REVOKE ALL ON TABLE pga_reports FROM tommi;
GRANT ALL ON TABLE pga_reports TO tommi;
GRANT ALL ON TABLE pga_reports TO PUBLIC;


--
-- Name: pga_scripts; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE pga_scripts FROM PUBLIC;
REVOKE ALL ON TABLE pga_scripts FROM tommi;
GRANT ALL ON TABLE pga_scripts TO tommi;
GRANT ALL ON TABLE pga_scripts TO PUBLIC;


--
-- Name: stamannschaft; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE stamannschaft FROM PUBLIC;
REVOKE ALL ON TABLE stamannschaft FROM tommi;
GRANT ALL ON TABLE stamannschaft TO tommi;
GRANT ALL ON TABLE stamannschaft TO PUBLIC;


--
-- Name: stamannschaftp; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE stamannschaftp FROM PUBLIC;
REVOKE ALL ON TABLE stamannschaftp FROM tommi;
GRANT ALL ON TABLE stamannschaftp TO tommi;
GRANT ALL ON TABLE stamannschaftp TO PUBLIC;


--
-- Name: status; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE status FROM PUBLIC;
REVOKE ALL ON TABLE status FROM postgres;
GRANT ALL ON TABLE status TO postgres;
GRANT SELECT ON TABLE status TO PUBLIC;


--
-- Name: stawertung; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE stawertung FROM PUBLIC;
REVOKE ALL ON TABLE stawertung FROM tommi;
GRANT ALL ON TABLE stawertung TO tommi;
GRANT ALL ON TABLE stawertung TO PUBLIC;


--
-- Name: stawettkampf; Type: ACL; Schema: public; Owner: tommi
--

REVOKE ALL ON TABLE stawettkampf FROM PUBLIC;
REVOKE ALL ON TABLE stawettkampf FROM tommi;
GRANT ALL ON TABLE stawettkampf TO tommi;
GRANT ALL ON TABLE stawettkampf TO PUBLIC;


--
-- Name: urkunde; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE urkunde FROM PUBLIC;
REVOKE ALL ON TABLE urkunde FROM postgres;
GRANT ALL ON TABLE urkunde TO postgres;
GRANT ALL ON TABLE urkunde TO PUBLIC;


--
-- Name: verein; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE verein FROM PUBLIC;
REVOKE ALL ON TABLE verein FROM postgres;
GRANT ALL ON TABLE verein TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE verein TO PUBLIC;


--
-- Name: wertung; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE wertung FROM PUBLIC;
REVOKE ALL ON TABLE wertung FROM postgres;
GRANT ALL ON TABLE wertung TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE wertung TO PUBLIC;


--
-- Name: wertungak; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE wertungak FROM PUBLIC;
REVOKE ALL ON TABLE wertungak FROM postgres;
GRANT ALL ON TABLE wertungak TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE wertungak TO PUBLIC;


--
-- Name: wertungakv2; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE wertungakv2 FROM PUBLIC;
REVOKE ALL ON TABLE wertungakv2 FROM postgres;
GRANT ALL ON TABLE wertungakv2 TO postgres;
GRANT SELECT ON TABLE wertungakv2 TO PUBLIC;


--
-- Name: wgruppe; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE wgruppe FROM PUBLIC;
REVOKE ALL ON TABLE wgruppe FROM postgres;
GRANT ALL ON TABLE wgruppe TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE wgruppe TO PUBLIC;


--
-- Name: wgruppewer; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE wgruppewer FROM PUBLIC;
REVOKE ALL ON TABLE wgruppewer FROM postgres;
GRANT ALL ON TABLE wgruppewer TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE wgruppewer TO PUBLIC;


--
-- PostgreSQL database dump complete
--

