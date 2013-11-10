shp2pgsql -d -D -t 2D -s 26911 RoadCentrelines.shp kelowna.roads_new | psql -d road_overlays
shp2pgsql -d -D -t 2D -s 26911 Lanes.shp kelowna.lanes_new | psql -d road_overlays

psql -d road_overlays -f load.sql
