CREATE OR REPLACE FUNCTION public.simple_expand(name TEXT, expansions hstore)
RETURNS TEXT AS $$
  SELECT string_agg(COALESCE(expansions -> part,part),' ')
    FROM (SELECT regexp_split_to_table(name,' +') AS part) AS split
$$ LANGUAGE SQL;


