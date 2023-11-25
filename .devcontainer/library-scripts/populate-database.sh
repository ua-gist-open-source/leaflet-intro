!/bin/bash

echo "Cloning osm-styles geoserver data_dir..."
git clone https://github.com/geosolutions-it/osm-styles.git

echo "Downloading osm-lowres.gpkg..."
curl -L https://www.dropbox.com/s/bqzxzkpmpybeytr/osm-lowres.gpkg?dl=1 -o osm-styles/data/osm-lowres.gpkg

echo "Starting docker services postgres, geoserver, nginx"
docker compose up -d

tries=0
echo "Testing to see if postgresql is running..."
until psql -c "select 1" > /dev/null
do
    "postgresql is not running yet. sleeping 5..."
    sleep 5
    tries=$(expr $tries + 1)
    if [ $tries -gt 12 ]; then
        echo postgresql does not seem to be running
        exit 1
    fi
done
echo "postgresql is running..."

echo "Creating the OSM database and enabling extensions..."
psql -U postgres -c "CREATE DATABASE hawaii"
psql -U postgres -d hawaii -c "CREATE EXTENSION postgis"
psql -U postgres -d hawaii -c "CREATE EXTENSION hstore"

echo "Downloading pbf..."
curl -L -O https://download.geofabrik.de/north-america/us/hawaii-latest.osm.pbf -o hawaii-latest.osm.pbf

echo "Importing pbf into postgresql..."
/opt/imposm/imposm-0.11.1-linux-x86-64/imposm import -mapping osm-styles/imposm/mapping.yml -read hawaii-latest.osm.pbf -overwritecache -write -connection postgis://postgres:postgres@localhost/hawaii

echo "removing hawaii-latest.osm.pbf"
rm hawaii-latest.osm.pbf

tries=1
until curl http://localhost:8080/geoserver/web
do
    "geoserver is not running yet after $tries tries. sleeping 5..."
    sleep 5
    tries=$(expr $tries + 1)
    if [ $tries -gt 15 ]; then
        echo geoserver does not seem to be running. Giving up. 
        exit 1
    fi
done
echo "geoserver is running..."

echo "Fixing osm datastore..."
# CREATE DATASTORE
curl -v -u admin:geoserver -H 'Content-type: application/json' -XPUT http://localhost:8080/geoserver/rest/workspaces/osm/datastores/osm -d '
{
  "dataStore": {
    "name": "osm",
    "connectionParameters": {
      "entry": [
        {"@key":"host","$":"'postgis'"},
        {"@key":"port","$":"'5432'"},
        {"@key":"database","$":"'hawaii'"},
        {"@key":"user","$":"'postgres'"},
        {"@key":"passwd","$":"'postgres'"},
        {"@key":"schema","$":"import"},
        {"@key":"dbtype","$":"postgis"}
      ]
    }
  }
}'


