echo "downloading city of kelowna data"

FILES='RoadCentrelines Lanes'

for f in $FILES
do
	echo "Downloading $f"
	r="${f}_SHP.zip"
	curl -L -z "$r" -o "$r" "http://www.kelowna.ca/images/opendata/$r"
	unzip -uqq -d ./ "$r" "$f.shp" "$f.shx" "$f.prj" "$f.dbf" &
done

echo "Waiting for decompression to finish"
wait

