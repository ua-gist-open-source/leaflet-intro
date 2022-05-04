# Leaflet Intro

## Background
Leaflet (https://leafletjs.com/) is an open source javascript library for serving mobile friendly maps. Look around https://leafletjs.com/index.html for some background on the project and features of the library, as well as documentation. 

## Assignment
Check out this repo to your computer and perform the following work in a branch named `leaflet`:

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
  - `traffic`# Leaflet Intro

## Background
Leaflet (https://leafletjs.com/) is an open source javascript library for serving mobile friendly maps. Look around https://leafletjs.com/index.html for some background on the project and features of the library, as well as documentation. 

## Assignment
Check out this repo to your computer and perform the following work in a branch named `leaflet`:

### Deliverables:
1) screenshot: `screencap-terrain-icecap.png`
2) screenshot: `screencap-terrain-iceland.png`
3) screenshot: `screencap-getting-started.png`
4) screenshot: `screencap-leaflet-geoserver-osm.png`
5) screenshot: `screencap-docker-compose-geoserver-osm.png`
6) new file: `docker-compose.yml`
7) new file: `geoserver.html`
8) modified file: `Dockerfile`


### 0. Prerequisites
- **Knowledge**:
  - Basic knowledge of HTML
  - Basic knowledge of Javascript
- **Environment**:
  - PostGIS Database of OpenStreetMap data (i.e., `iceland-latest.osm.pbf`) imported using `imposm` from a previous assignment
  - Geoserver workspace `osm`
  - Geoserver layergroup `osm:osm`
  - docker network named `gist604b` created with `docker network create gist604b`

_Important: If the **Environment** prerequisites are not met, see [INITIALIZING.md](INITIALIZING.md)_

### 1. Getting started with Leaflet:
Refer to the following 
https://leafletjs.com/examples/quick-start/

I have included a starter file in this repository to help you get started that represents the working map up to the quick-start section labeled "Markers, circles and polygons"

- [getting-started.html](getting-started.html)

Open the `getting-started.html` file in your local browser and confirm the map is visible and interactive.

Note that this file is local, on your computer, and it is making network calls out to a url ending in `tile.openstreetmap.org` to fetch tiles from an OSM tile map service. You can make modifications to this file and reload it in your browser to see changes instantly.

### Modify `getting-started.html` for different options.

First, modify the url of the tile service. Instead of using `tile.openstreetmap.org`, we will change it to a service in the `tile.stamen.com` domain. We comment out this line:
```
    var osmUrl='http://tile.stamen.com/terrain-background/{z}/{x}/{y}.png'
```
with `//` like this:
```
    // var osmUrl='http://tile.stamen.com/terrain-background/{z}/{x}/{y}.png'
```
and add a new line for a different tile service:
```
    // var osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    var osmUrl='http://tile.stamen.com/terrain-background/{z}/{x}/{y}.png'
```
Reload the `getting-started.html` and verify that the background map has been changed to a terrain map.

Take a screenshot, making sure the url is visible in the browser screenshot, and save this as `screencap-terrain-icecap.png`

Next, change the initial lat/long to `64.96, -19.02` and zoom level to `6` by changing the line that declares `var map`:

When you reload `getting-started.html` you should now see all of Iceland rendered by the terrain tile map service. 

Take a screenshot, making sure the url is visible in the browser screenshot, and save this as `screencap-terrain-iceland.png`

### 2. Run in docker

A [Dockerfile](Dockerfile) is provided that will add the `getting-started.html` file to an `nginx` web server. This is a web server that will serve HTML pages. Since our `getting-started.html` is just a plain webpage, this is a simple way of serving our map page.

By default the container exposes port 80 but we will forward that to a more obscure local host port so we don't get confused when we try to run this from `docker-compose` later. 
```
docker build . -t <docker-usermame>/leaflet-intro
```
then run it with:
```
docker run -p 8880:80 --rm --name leaflet-intro <docker-username>/leaflet-intro
```
It will start up very quickly. Open http://localhost:8880/getting-started.html in your browser. If all is well, then you will see the same interactive map.

Take a screenshot, making sure the url is visible in the browser screenshot, and save it as `screencap-docker-getting-started.png`

_Note that any time you make changes to `getting-started.html`, they will need to be added to your Dockerfile and a new image built, so these instructions ^ must be repeated._ 

Side note on the docker network: We did not have to specify the docker network when we ran the leaflet-intro. Why?

### 3. Rebuild the docker image with a different background
Stamen has a few other styles of tile maps we can try out. Let's try `toner`. Change the `osmUrl` value to `'http://tile.stamen.com/toner/{z}/{x}/{y}.png'` and refresh your `getting-started.html` page to see it in effect. Now reload the page http://localhost:8880/getting-started.html. Did it change? Why not?

The docker container that is running is still using the old `getting-started.html`. You will need to rebuild the image AND run a new container to get the latest copy of `getting-started.html.`

Stop the current running docker container with
```
docker kill lealet-intro
```
then build a new image and run a new container:
```
docker build -t <docker-username>/leaflet-intro
docker run -p 8880:80 --rm --name leaflet-intro <docker-username>/leaflet-intro
```
Now check out http://localhost:8880/getting-started.html and verify the toner map is rendered.

Take a screenshot, making sure the url is visible in the browser screenshot, and save it as `screencap-docker-toner.png`

### 5. Add a WMS from geoserver to your Leaflet Map
Now that you have proven that the container works, stop this container. We confirmed it was working by itself but we want to bundle this webserver with the postgis database and geoserver containers that we were running from a previous assignment. Use `docker ps`, `docker kill`, and `docker rm` commands on the command line to stop/remove any running containers or else use Docker Desktop and do it with the GUI.

#### 5a. Migrate your docker-compose.yml from the previous assignment to this repo
In a previous assignment we used `docker compose` to start up two containers simultaneously: one running `postgis` and another running `geoserver`. In this assignment we are going to add another to run a webserver that will serve an HTML page that embeds javascript that uses the `leaflet.js` javascript library.

In a typical docker compose use case, as we build onto a project, we would be using the same `git` repo and make a new branch with new edits to our original `docker-compose.yml` file. However, our use of github classroom makes that slightly awkward so I'm asking that you do a couple of setup items to make this assignment work. 

The TL;DR is that we are going to shut down the previous docker compose we had running and copy the docker-compose.yml file to this repo and run it
from here, in a new branch.

1. Stop your current running docker containers related to previous assignments. There are several ways to do this.
    Preferred: 
    
    a. Navigate in a terminal (i.e., cmd or Powershell for windows users) to the directory containing the `docker-compose.yml` of the _previous assignment_
    and run 
    ```
    docker compose down
    ```
    
   b. Use your Docker Desktop to kill all running docker containers
   
   c. Restart Docker Desktop
   
   d. From a terminal, use `docker ps` and `docker kill <pid>` to kill all running processes
   
2. Copy the `docker-compose.yml` file you created with OSM styles in geoserver to this directory and this repo. This assumes you've checked the repo out to your computer and created a new branch. 

#### 5b. Bring up `postgis` and `geoserver` with docker compose from this repo
Fix the `docker-compose.yml` in this repo with your postgis and geoserver directories and then:
```
docker-compose up -d
```
To make sure they are running, do `docker ps` to verify that you have both geoserver and postgis running.

*Note that we are not yet running leaflet in docker. This step is incremental towards our end goal*

Read the example at https://leafletjs.com/examples/wms/wms.html.

Create a brand new file named `geoserver.html` and copy the contents of `getting-started.html` as a starting point. You are going to add a new layer based on your own geoserver layer group named `osm:osm` from a previous assignment. Note that you will want to update the initial map coordinates, depending on what state you have chosen for your database. Otherwise anybody using your map will have to pan the world to find your OSM WMS data.

As you read the example, note some differences in the urls of their example. For the `geoserver.html` file we will remove the references to `var osmUrl`, `var osmAttrib`, and `var osm` and remove the line that adds the `osm` layer to the map. Specifically, we will remove these lines:
```
    var osmUrl='http://tile.stamen.com/toner/{z}/{x}/{y}.png'
    var osmAttrib='Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
    var osm = new L.TileLayer(osmUrl, {minZoom: 3, maxZoom: 18, attribution: osmAttrib});
    map.addLayer(osm);
```
and replace them with this:
```
    var wmsLayer= L.tileLayer.wms("http://localhost:8280/geoserver/osm/wms", {
        layers: 'osm:osm',
        format: 'image/png',
        transparent: true
    });
    map.addLayer(wmsLayer)
```  

Save the `geoserver.html` page and open it in your browser. You should see the symbology from your WMS after a brief wait. If not, then something went wrong. In that case, open your Developer Tools and look at the `console` and the `network` activity to see if you can debug any errors.

Note that this is still only a local file and doesn't exist yet in your docker container. In fact, if we run `docker build .` again, The `Dockerfile` doesn't know about this file yet so it will not be added to the container anyway. To include it in the docker container: edit [Dockerfile](Dockerfile), adding a new line with:
```
COPY geoserver.html /usr/share/nginx/html/geoserver.html
```
Then rebuild your docker image:
```
docker build . -t <docker-usermame>/leaflet-intro
```

### 6. Add leaflet to docker-compose
Next, create a new service in your docker-compose environment. Add the following service to the `docker-compose.yml` file. Note that as a `yml` file the indentation level is critical so make sure your `leaflet` service is at the same indentation of `postgis` and `geoserver` or else it won't parse.
```
  leaflet:
    image: <docker-usermame>/leaflet-intro
    ports:
      - "8888:80"
    depends_on:
      - geoserver
```
Notice that we used the port `8888` instead of `8880`. This is really just to make sure we are using the docker-compose version rather than the docker version you ran before.

After updating the `docker-compose.yml` file, run `docker-compose down` to shut down the currently running postgis and geoserver services and then `docker-compose up` to bring them all back up alongside `leaflet`. Note that if this is the first time running `docker-compose up` after adding a new service, it will pull the docker image and run it fresh. However, if you have changed the configuration of a container _that has already been created_, then `docker-compose up` will NOT re-load the container. We'll show how to deal with this scenario shortly.

After they have come up (geoserver will be last), open http://localhost:8888/geoserver.html in your browser to see if it loaded correctly.

Take a screenshot, making sure the url is visible in the browser screenshot, and save it as `screencap-leaflet-geoserver-osm.png`

**Important!** Read this carefully if you have to make changes to your `docker-compose.yml` file
1) If you try to restart a container running through docker-compose with `docker-compose restart leaflet` it will NOT create a new container so it will not know about any changes you have made to the docker image or the configuration. This is true about `docker-compose stop leaflet` followed by `docker-compose start leaflet`. Docker-compose wants to re-use those old containers.
2) If you try to force docker-compose to restart a specific container with `--force-restart` then it will also force restart any dependent containers. Since leaflet is dependent on `geoserver` and `geoserver` is dependent on `postgis`, this will cause them all to be reloaded fresh. This may not be what you want.
3) to restart JUST ONE of the containers: ```docker-compose restart --force-restart --no-deps leaflet```

## Epilogue
Congratulations, you are running  a full GIS stack with geospatial backend served by OGC-compliant web services which are consumed by not just your desktop client (QGIS) but also a web client. And to boot, it is all served from a small config file. Even better, you can take this `docker-compose.yml` file and run it _anywhere_ that docker can run. It would be trivial to run this in an environment that facilitated auto-scaling so that you could ramp up from one to hundreds or thousands of copies of your webapp to accomodate a dynamic load.

## Troubleshooting tips
- The Developer Toolbox is your friend!

## Deliverable: Pull Request in `leaflet` branch with:
1) screenshot: `screenshot-getting-started.png`
2) modified file: `docker-compose.yml`
3) new file: `geoserver.html`
4) modified file: `Dockerfile`
5) new file: `docker-compose-geoserver-screenshot.png` - screenshot showing WMS being served by leaflet 

  - `traffic_a`
  - `transport`
  - `transport_a`
  - `water_a`
  - `waterways`
- Geoserver Layergroup named `osm` in the `osm` workspace containing the 18 layers listed above
- Custom SLDs for the layers above
- docker network named `gist604b` created with `docker network create gist604b`

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

_Note that any time you make changes to `getting-started.html`, they will need to be added to your Dockerfile and a new image built, so these instructions ^ must be repeated._ 

Side note on the docker network: We did not have to specify the docker network when we ran the leaflet-intro. Why?

### 3. Shut down the container with `docker stop`
Now that you have proven that the container works, stop the container. We are going to have it start up in the `docker-compose.yml` config with the other services. To see what docker containers are running:
```
docker ps
```
If the leaflet-intro container is running:
```
docker stop leaflet-intro
```

### 4. Rebuild the docker image
The starting location for the map is defined with
```
    var map = new L.Map('map', { center: new L.LatLng(21.38,-157.8), zoom: 6, attributionControl:true, zoomControl:false, minZoom:6});  
```
where `21.38,-157.8` is the lat/long of Hawaii. We want to change the starting location to be your home town (or any other place on earth if you happen to live at `21.38,-157.8`). To do this, we need to edit the `getting-started.html` page and rebuild the docker container:

1) Edit the `getting-started.html` page, changing the map initialization coordinate.
2) Rebuild the container with `docker build . -t <docker-usermame>/leaflet-intro`
3) Restart the container with `docker run -p 8880:80 --rm --name leaflet-intro <docker-username>/leaflet-intro`

Visit  http://localhost:8880/getting-started.html to verify the starting location is different. 

_Deliverable: Take a screenshot of the initial page of getting-started.html and name it `screenshot-getting-started.png`_

### 5. Add a WMS from geoserver to your Leaflet Map

#### 5a. Migrate your docker-compose.yml from the previous assignment to this repo
In a previous assignment we used `docker compose` to start up two containers simultaneously: one running `postgis` and another running `geoserver`.
In this assignment we are going to add another to run a webserver that will serve an HTML page that embeds javascript that uses the `leaflet.js`
javascript library.

In a typical docker compose use case, as we build onto a project, we would be using the same `git` repo and make a new branch with new edits to
our original `docker-compose.yml` file. However, our use of github classroom makes that slightly awkward so I'm asking that you do a couple of setup items
to make this assignment work. 

The TL;DR is that we are going to shut down the previous docker compose we had running and copy the docker-compose.yml file to this repo and run it
from here, in a new branch.

1. Stop your current running docker containers related to previous assignments. There are several ways to do this.
    Preferred: 
    
    a. Navigate in a terminal (i.e., cmd or Powershell for windows users) to the directory containing the `docker-compose.yml` of the _previous assignment_
    and run 
    ```
    docker compose down
    ```
    
   b. Use your Docker Desktop to kill all running docker containers
   
   c. Restart Docker Desktop
   
   d. From a terminal, use `docker ps` and `docker kill <pid>` to kill all running processes
   
2. Copy your `docker-compose.yml` file to this directory and this repo. This assumes you've checked the repo out to your computer and created a new branch. 

#### 5b. Bring up `postgis` and `geoserver` with docker compose from this repo
Fix the `docker-compose.yml` in this repo with your postgis and geoserver directories and then:
```
docker-compose up -d
```
To make sure they are running, do `docker ps` to verify that you have both geoserver and postgis running.

Read the example at https://leafletjs.com/examples/wms/wms.html.

Create a brand new file named `geoserver.html` and copy the contents of `getting-started.html` as a starting point. You are going to add a new layer based on your own geoserver layer group named `osm:osm` from a previous assignment. Note that you will want to update the initial map coordinates, depending on what state you have chosen for your database. Otherwise anybody using your map will have to pan the world to find your OSM WMS data.

As you read the example, note some differences in the urls of their example. You will add the following two commands _after_ the commands that add the generic OSM map. This goes in your `geoserver.html` page:

```
    var wmsLayer= L.tileLayer.wms("http://localhost:8080/geoserver/osm/wms", {
        layers: 'osm:osm',
        format: 'image/png',
        transparent: true
    });
    map.addLayer(wmsLayer)
```  

Save the `geoserver.html` page and open it in your browser. You should see the symbology from your WMS. If not, then something went wrong. In that case, open your Developer Tools and look at the `console` and the `network` activity to see if you can debug any errors.

Note that this is still only a local file and doesn't exist yet in your docker container. In fact, if we run `docker build .` again, The `Dockerfile` doesn't know about this file yet so it will not be added to the container anyway. To include it in the docker container: edit [Dockerfile](Dockerfile), adding a new line with:
```
COPY geoserver.html /usr/share/nginx/html/geoserver.html
```
Then rebuild your docker image:
```
docker build . -t <docker-usermame>/leaflet-intro
```

### 6. Add leaflet to docker-compose
Next, create a new service in your docker-compose environment. Add the following service to the `docker-compose.yml` file. Note that as a `yml` file the indentation level is critical so make sure your `leaflet` service is at the same indentation of `postgis` and `geoserver` or else it won't parse.
```
  leaflet:
    image: <docker-usermame>/leaflet-intro
    ports:
      - "8888:80"
    depends_on:
      - geoserver
 ```
After updating the `docker-compose.yml` file, run `docker-compose down` to shut down the currently running postgis and geoserver services and then `docker-compose up` to bring them all back up alongside `leaflet`. Note that if this is the first time running `docker-compose up` after adding a new service, it will pull the docker image and run it fresh. However, if you have changed the configuration of a container _that has already been created_, then `docker-compose up` will NOT re-load the container. We'll show how to deal with this scenario shortly.

After they have come up (geoserver will be last), open http://localhost/geoserver.html in your browser to see if it loaded correctly.

**Important!** Read this carefully if you have to make changes to your `docker-compose.yml` file
1) If you try to restart a container running through docker-compose with `docker-compose restart leaflet` it will NOT create a new container so it will not know about any changes you have made to the docker image or the configuration. This is true about `docker-compose stop leaflet` followed by `docker-compose start leaflet`. Docker-compose wants to re-use those old containers.
2) If you try to force docker-compose to restart a specific container with `--force-restart` then it will also force restart any dependent containers. Since leaflet is dependent on `geoserver` and `geoserver` is dependent on `postgis`, this will cause them all to be reloaded fresh. This may not be what you want.
3) to restart JUST ONE of the containers: ```docker-compose restart --force-restart --no-deps leaflet```

Take a screenshot of your browser once you have loaded the WMS through leaflet and name it `screencap-docker-compose-geoserver-osm.png` to show that you have successfully completed the assignment.

## Epilogue
Congratulations, you are running  a full GIS stack with geospatial backend served by OGC-compliant web services which are consumed by not just your desktop client (QGIS) but also a web client. And to boot, it is all served from a small config file. Even better, you can take this `docker-compose.yml` file and run it _anywhere_ that docker can run. It would be trivial to run this in an environment that facilitated auto-scaling so that you could ramp up from one to hundreds or thousands of copies of your webapp to accomodate a dynamic load.

## Troubleshooting tips
- The Developer Toolbox is your friend!

## Deliverable: Pull Request in `leaflet` branch with:
1) screenshot: `screencap-terrain-icecap.png`
2) screenshot: `screencap-terrain-iceland.png`
3) screenshot: `screencap-getting-started.png`
4) screenshot: `screencap-leaflet-geoserver-osm.png`
5) screenshot: `screencap-docker-compose-geoserver-osm.png`
6) modified file: `docker-compose.yml`
7) new file: `geoserver.html`
8) modified file: `Dockerfile`
