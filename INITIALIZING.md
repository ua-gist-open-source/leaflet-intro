# Initializing PostGIS and Geoserver for this assignment

First, bring the services up:
```
docker-compose up
```
Next, populate the database. This example uses `iceland`.
```
docker run --network gist604b -e STATE=iceland -e REGION=europe -e DATABASE=iceland aaryno/populate-docker-webgis populate-postgis.sh
```
If successful, you'll see the output of the `shp2pgsl` and `psql` INSERTs.
Next, create the geoserver components. This will create layers for all the DB tables you just created as well as a layer group with three of the layers named `osm:osm`:
```
docker run --network gist604b -e STATE=iceland -e REGION=europe -e DATABASE=iceland aaryno/populate-docker-webgis populate-geoserver.sh
```
That's it.

## Source of aaryno/populate-docker-geo
See https://github.com/ua-gist-open-source/docker-compose-populate to update or rebuild the aaryno/populate-docker-webgis image.

## To see if things are working:

### Geoserver Running:
```
docker run --network gist604b aaryno/populate-docker-geo curl -u admin:geoserver http://geoserver:8280/geoserver/rest/workspaces
```
### PostGIS Installed in your database:
```
docker-compose exec postgis psql -d iceland -U postgres -c "select postgis_full_version()"
```
### PostGIS database has data:
```
docker-compose exec postgis psql -d iceland -U postgres -c "select count(*) from waterways"
```
