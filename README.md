# Leaflet Intro

## Background
Leaflet (https://leafletjs.com/) is an open source javascript library for serving mobile friendly maps. Look around https://leafletjs.com/index.html for some background on the project and features of the library, as well as documentation. 

## Assignment

### 0. Prerequisites
- Basic knowledge of HTML
- Basic knowledge of Javascript
- PostGIS Database from a previous assignment populated with OSM data from a US state
- Geoserver workspace `osm
- Geoserver layers for all tables:
  - `buildings_a`
  - `landuse_a`
  - `nature`
  - `nature_a`
  - `places`
  - `places_a`
  - `pofw`
  - `pofw_a`
  - `pois`
  - `pois_a`
  - `railways`
  - `roads`
  - `traffic`
  - `traffic_a`
  - `transport`
  - `transport_a`
  - `water_a`
  - `waterways`
- Geoserver Layergroup named `osm` in the `osm` workspace containing the 18 layers listed above
- Custom SLDs for the layers above

_Important: If the prerequisites are not met, see [INITIALIZING.md](INITIALIZING.md)_

### 1. Getting started with Leaflet:
Refer to the following 
https://leafletjs.com/examples/quick-start/

I have included a starter file in this repository to help you get started that represents the working map up to the section labeled "Markers, circles and polygons"

- [getting-started.html](getting-started.html)

Open the getting-started.html file in your local browser and confirm the map is visible and interactive.

### 2. Run in docker

A [Dockerfile](Dockerfile) is provided that will add the `getting-started.html` file to an `nginx` web server. By default it exposes port 80 but we will forward that to a more obscure local host port so we don't get confused when we try to run this from `docker-compose` later. 
```
docker build . -t <docker-usermame>/leaflet-intro
```
then run it with:
```
docker run -p 8880:80 --rm --name leaflet-intro <docker-username>/leaflet-intro
```
It will start up very quickly. Next, open http://localhost:8880/getting-started.html in your browser. If all is well, then you will see the same interactive map.

_Note that any time you make changes to `getting-started.html`, they will need to be added to a new Dockerfile, so these instructions ^ must be repeated._ 

### 3. Shut down the container with `docker stop`
Now that you have proven that the container works, stop the container. We are going to have it start up in the `docker-compose.yml` config with the other services. To see what docker containers are running:
```
docker ps
```
If the leaflet-intro container is running:
```
docker stop leaflet-intro
```

### 4. Add a WMS from geoserver to your Leaflet Map

Read the example at https://leafletjs.com/examples/wms/wms.html.

Create a new file named `geoserver.html` and copy the contents of `getting-started.html` as a starting point. You are going to add a new layer based on your own geoserver layer group named `osm:osm` from a previous assignment. Note that the initial map coordinates are set in this line:
```
    var map = new L.Map('map', { center: new L.LatLng(21.38,-157.8), zoom: 6, attributionControl:true, zoomControl:false, minZoom:6});  
```
Which is centered on Hawaii. If you are using a different state, you will need to find the coordinates that make most sense for that state or else you will have to pan the world to find your OSM WMS data.

As you read the example, note some differences in the urls of their example. You will add the following two commands _after_ the commands that add the generic OSM map.

```
    var wmsLayer= L.tileLayer.wms("http://localhost:8080/geoserver/osm/wms", {
        layers: 'osm:osm',
        format: 'image/png',
        transparent: true
    });
    map.addLayer(wmsLayer)
```  

Save the `geoserver.html` page and open it in your browser. Note that this is only a local file and doesn't exist yet in your docker container. We are going to add it to the docker container. In the file [Dockerfile](Dockerfile), add a new line with:
```
COPY geoserver.html /usr/share/nginx/html/geoserver.html
```
Then rebuild your docker image:
```
docker build . -t <docker-usermame>/leaflet-intro
```
Next, create a new service in your docker-compose environment. Add the following service to the docker-compose file. 
```
  leaflet:
    image: <docker-usermame>/leaflet-intro
    ports:
      - "80:80"
    depends_on:
      - geoserver
 ```
After updating the docker-compose.yml file, run `docker-compose down` to shut down the currently running postgis and geoserver services and then `docker-compose up` to bring them all back up alongside `leaflet`. Note that if this is the first time running `docker-compose up` after adding a new service, it will pull the docker image and run it fresh. However, if you have changed the configuration of a container _that has already been created_, then `docker-compose up` will NOT re-load the container. We'll show how to deal with this scenario shortly.

After they have come up (geoserver will be last), open http://localhost/geoserver.html in your browser to see if it loaded correctly.

**Important!** Read this carefully if you have to make changes to your `docker-compose.yml` file
1) If you try to restart a container running through docker-compose with `docker-compose restart leaflet` it will NOT create a new container so it will not know about any changes you have made to the docker image or the configuration. This is true about `docker-compose stop leaflet` followed by `docker-compose start leaflet`. Docker-compose wants to re-use those old containers.
2) If you try to force docker-compose to restart a specific container with `--force-restart` then it will also force restart any dependent containers. Since leaflet is dependent on `geoserver` and `geoserver` is dependent on `postgis`, this will cause them all to be reloaded fresh. This may not be what you want.
3) to restart JUST ONE of the containers: ```docker-compose restart --force-restart --no-deps leaflet```

Take a screenshot of your browser once you have loaded the WMS through leaflet and name it `docker-compose-geoserver-screenshot.png` to show that you have successfully completed the assignment.

## Epilogue
Congratulations, you are running  a full GIS stack with geospatial backend served by OGC-compliant web services which are consumed by not just your desktop client (QGIS) but also a web client. And to boot, it is all served from a small config file.

## Troubleshooting tips
- The Developer Toolbox is your friend!

## Deliverable: Pull Request in `leaflet` branch with:
1) modified file: `docker-compose.yml`
2) new file: `geoserver.html`
3) modified file: `Dockerfile`
4) new file: `docker-compose-geoserver-screenshot.png` - screenshot showing WMS being served by leaflet 
