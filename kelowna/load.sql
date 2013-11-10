SET search_path TO kelowna,public;

BEGIN;
CREATE TEMPORARY TABLE expansions 
  (short_name text PRIMARY KEY,
  long_name text);
INSERT INTO expansions
   VALUES
    ('ST','Street'),
    ('RD','Road'),
    ('DR','Drive'),
    ('AVE','Avenue'),
    ('PL','Place'),
    ('N','North'),
    ('E','East'),
    ('S','South'),
    ('W','West'),
    ('HWY','Highway'),
    ('CT','Court');

CREATE OR REPLACE FUNCTION pg_temp_2.end_type(code double precision)
  RETURNS TEXT AS $$
  BEGIN
    CASE code
      WHEN 999990,999991,999992,999993 THEN
        RETURN 'END';
      WHEN 999994 THEN
        RETURN 'DEAD';
      WHEN 999988 THEN
        RETURN 'LIMIT';
      WHEN 999987,999989 THEN
        RETURN 'WATER';
      ELSE
        RETURN NULL;
    END CASE;
  END;
  $$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS roads;
CREATE TABLE roads
  AS
    SELECT
        ST_Transform(geom,900913) AS geom,
        road_id, road_name, 
        simple_expand(road_name,(SELECT hstore(array_agg(short_name),array_agg(long_name)) FROM expansions)) AS expanded_name,
        road_type, seg_type,
        gis_start AS start_addr, gis_end AS end_addr, odd_side,
        pg_temp_2.end_type(frm_id) AS from_end, pg_temp_2.end_type(to_id) AS to_end
      FROM roads_new
      ORDER BY ST_GeoHash(ST_Transform(geom,4326));

CREATE INDEX ON roads USING gist (geom) WITH (fillfactor=100);
ANALYZE roads;
GRANT SELECT ON kelowna.roads TO "www-data";
COMMIT;

BEGIN;
DROP TABLE IF EXISTS lanes;
CREATE TABLE lanes
  AS
    SELECT
        ST_Transform(geom,900913) AS geom,
        laneseg_id
      FROM lanes_new
      ORDER BY ST_GeoHash(ST_Transform(geom,4326));

CREATE INDEX ON lanes USING gist (geom) WITH (fillfactor=100);
ANALYZE lanes;
GRANT SELECT ON kelowna.lanes TO "www-data";
COMMIT;

