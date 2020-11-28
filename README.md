# Leaflet Intro

## Background
Leaflet (https://leafletjs.com/) is an open source javascript library for serving mobile friendly maps. Look around https://leafletjs.com/index.html for some background on the project and features of the library, as well as documentation. 

## Assignment

### 0. Prerequisites
Have geoserver and postgis running from a previous assignment in a docker-compose yaml with an OSM dataset loaded into PostGIS and geoserver serving an `osm:osm` layer group. 

### 1. Getting started:
Refer to the following 
https://leafletjs.com/examples/quick-start/

I have included a starter file in this repository to help you get started that represents the working map up to the section labeled "Markers, circles and polygons"

- [getting-started.html](getting-started.html)

Open the getting-started.html file in your local browser and confirm the map is visible and interactive.

### 2. Run in docker

A [Dockerfile](Dockerfile) is provided that will add the `getting-started.html` file to an `nginx` web server. By default it exposes port 80
```
docker build .
```
Take note of the docker id that is built, then tag it with:
```
docker tag <docker-id> <docker-username>/leaflet-intro
```
then run it with:
```
docker run -p 80:80 <docker-username>/leaflet-intro
```
It will start up very quickly. Next, open http://localhost:80/getting-started.html in your browser. If all is well, then you will see the same interactive map.

_Note that any time you make changes to `getting-started.html`, they will need to be added to a new Dockerfile, so these instructions ^ must be repeated._ 

### 3. Add a WMS from geoserver to your Leaflet Map

Read the example at https://leafletjs.com/examples/wms/wms.html.

Create a new file named `geoserver.html` and copy the contents of `getting-started.html` as a starting point. You are going to add a new layer based on your own geoserver layer group named `osm:osm` from a previous assignment. 

As you read the example, note some differences in the urls of their example. You will add the following two commands _after_ the commands that add the generic OSM map.

```
    var wmsLayer= L.tileLayer.wms("http://localhost:8080/geoserver/osm/wms", {
        layers: 'osm:osm',
        format: 'image/png',
        transparent: true
    });
    map.addLayer(wmsLayer)
```  

Save the `geoserver.html` page and open it in your browser. If you have done it correctly you will see your styled geoserver layer shown in the web map. Note that this is only a local file and doesn't exist yet in your docker container.

### 4. Incorporate your geoserver.html file into docker-compose environment
Our last step is to package this into Docker Compose and deploy the whole stack together: `postgis`, `geoserver`, and `leaflet`. This will take two steps. First is to change the url for the WMS because the network inside docker-compose is different. Second is to add the new service definition to the docker-compose.yaml.

When we deploy leaflet in docker compose, we aren't accessing `localhost:8080` to get to geoserver. Instead we will use the service name, which is simply `geoserver`. So instead of `"http://localhost:8080/geoserver/osm/wms"`, we will use `"http://geoserver:8080/geoserver/osm/wms"` in the geoserver.html file. 

Add the following service to the docker-compose file you used in the PostGIS-Geoserver-OSM assignment. _While it may be easiest to re-use the docker-compose.yml file from the PostGIS-Geoserver-OSM assignment and simply add this service, I have included a sample docker-compose.yml in this repo for reference._
```
  leaflet:
    image: your-user-name/leaflet-intro
    ports:
      - "80:80"
    depends_on:
      - geoserver
 ```
After updating the docker-compose.yml file, run `docker-compose down` to shut down the currently running postgis and geoserver services and then `docker-compose up` to bring them all back up alongside `leaflet`. The nginx webserver that that leaflet container runs is very fast but since the map depends on our geoserver service being running, we added a `depends_on` attribute to the leaflet service definition so we can't accidentally try to get blank maps before geoserver is up and running.

After they have come up (geoserver will be last), open http://localhost/geoserver.html in your browser to see if it loaded correctly.

Take a screenshot of your browser and name it `docker-compose-geoserver-screenshot.png` to show that you have successfully completed the assignment.

Congratulations, you are running  a full GIS stack with geospatial backend served by OGC-compliant web services which are consumed by not just your desktop client (QGIS) but also a web client. And to boot, it is all served from a small config file.

## Troubleshooting tips
- The Developer Toolbox is your friend!

## Deliverable: Pull Request in `leaflet` branch with:
1) updated `docker-compose.yml`
2) `docker-compose-geoserver-screenshot.png` - screenshot showing WMS being served by leaflet 
