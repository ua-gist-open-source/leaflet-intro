[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-f4981d0f882b2a3f0472912d15f9806d57e124e0fc890972558857b51b24a6f9.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=9489988)
# Leaflet Intro

## Background
Leaflet (https://leafletjs.com/) is an open source javascript library for serving mobile friendly maps. Look around https://leafletjs.com/index.html for some background on the project and features of the library, as well as documentation. 

## Assignment
Check out this repo to your computer and perform the following work in a branch named `assignment`:

### 0. Prerequisites
- Basic knowledge of HTML
- Basic knowledge of Javascript

The following will have been created in a previous assignment but are provided with this codespace to work with:
- PostGIS Database from a previous assignment populated with OSM data from a US state
- Geoserver workspace `osm`
- Geoserver layers based on the `osm-styles` repo

## Background
Leaflet (https://leafletjs.com/) is an open source javascript library for serving mobile friendly maps. Look around https://leafletjs.com/index.html for some background on the project and features of the library, as well as documentation. 

## Assignment
Create a branch named `leaflet` and open a Codespace on the `leaflet` branch. 

The Codespace should initialize to the final state of the Geoserver-OSM-II assignment. That is, with a working PostGIS database populated with OSM data and a working geoserver with nice OSM styles and an `osm:osm` layergroup. Details are given in Environment Setup:

### Environment setup (already done for you):

During codespace creation, a script was run to initialize `postgis` and `geoserver` containers to match the final state of the assignment for Geoserver-OSM-Styles.

Review this script, [.devcontainer/library-scripts/populate-database.sh](.devcontainer/library-scripts/populate-database.sh) and see how this was done.

Notably, the steps we followed in a previous assignment were automated in this script in this order:
1) Clone the osm-styles repo.
2) Download the osm-lowres gpkg.
3) Start up `postgis` and `geoserver` with `docker compose up -d`
4) Wait for `postgis` to be ready and then:
5) Create the `hawaii` database and `postgis` extension.
6) Download the `hawaii-latest.osm.pbf` OSM import file from https://geofrabrik.de.
7) Run `imposm import` to populate the postgis `hawaii` database
8) Wait for geoserver to be ready (just in case it's not yet)
9) Use the geoserver REST API to fix the osm datastore for the `osm-styles`-based geoserver.

If you open the `docker-compose.yml` file you can find the `postgis` and `geoserver` services. The `postgis` service uses a named docker volume while the `geoserver` service uses the `git clone`d [osm-styles](https://github.com/geosolutions-it/osm-styles) repo as its DATA_DIR.

Deliverables are listed at the bottom.

**Important: Check the initialization** 
To double check this is configured correctly: 
1) Check that docker is running
  - In the terminal window type `docker ps`.
    - If no containers are listed, type this to run the initialization script: 
```
bash ./populate_database.sh
```` 
2) Check your geoserver to ensure that it shows the Hawaii OSM layers:
- Click on `Ports` in the `Terminal` codespace panel
- Select the `Open in Browser` option
- In the browser, add `/geoserver` to the URL to get to the geoserver landing page. 
- From the geoserver landing page, click `Layer Preview` from the left menu
- Find the layer named `osm:osm` and click `OpenLayers`

If the page loads a new tab with a Hawaii map then you are good. For any other issue, debug the errors that might be listed in the geoserver log.

### 1. Add leaflet to docker-compose.yml
In addition to `postgis` and `geoserver`, we need to run a webserver in order to serve our HTML page that contains leaflet.js map rendering code. The webserver we are using in [nginx](https://www.nginx.com/resources/glossary/nginx/), the most popular webserver on the web. 

The configuration is in [nginx/](nginx/). This also contains:
- [nginx/conf.d](nginx/conf.d) contains custom configuration to enable this to work in a codespace. 
- [nginx/html](nginx/html) contains content that will be served via http requests. Note that you will be editing and adding files in this directory. 

#### Setting up leaflet

Add the following service to your docker-compose.yml file. Be sure to line up the indentation of the `leaflet:` service declaration at the same depth as `postgis:` and `geoserver:`
```
  leaflet:
    image: "nginx:mainline-alpine"
    ports:
      - "80:80"
    volumes:
      - /workspaces/${RepositoryName}/nginx/html:/usr/share/nginx/html
      - /workspaces/${RepositoryName}/nginx/conf.d:/etc/nginx/conf.d
```
Once you have updated your docker compose file, run 
```
docker compose up -d
```

### 2. Getting started with Leaflet:
Refer to the following 
https://leafletjs.com/examples/quick-start/

I have included a starter file in this repository to help you get started that represents the working map up to the quick-start section labeled "Markers, circles and polygons"

- [html/index.html](html/index.html)

Open the `html/index.html` file in your local browser. To do this, click on the `Ports` tab in the VS Code Terminal panel and find Port `80`, which is where the leaflet docker container is running. Open the `Local Address` url in a browser. It will have two links: `getting-started.html` and `geoserver.html`. Click on the `getting-started.html` to open a new page containing a leaflet map.

Confirm the map is visible and interactive. It should be zoomed initially to the big island of Hawaii.

Note that this container is actually just running a small webserver serving files from your `html` directory in this codespace. There is a single file, `index.html`, which is what the web server, nginx, will serve by default if a file path is not given. There is a `getting-started.html` file as well. If you add additional files to the `html` directory they will be accessible from your web browser by appending the filenames to the Local Address url.

### 3. Modify `getting-started.html` for different options.

In VS Code, open the `html/getting-started.html` file. 
There are three sections worth describing.
#### <head>
In the `<head>` section, there are two lines that import leaflet-related files:
- `<link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" .../>`
  - Imports the CSS (Styles) for leaflet
- `<script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js" ...`
  - Imports the `leaflet.js` javascript library for use in `<script>`s

#### <body>
In the `<body>` there are two elements to note:
- `<div id="map" style="width: 600px; height: 400px;"></div>`
  - This is an HTML element that will be where our slippy map is rendered.
- `<script>....`
  - This contains the relevant javascript for initializing our leaflet map.

The main section of this file we are changing is in the `<script>` section:
```
    var map = new L.Map('map', { center: new L.LatLng( 19.5429, -155.6659), zoom: 8, attributionControl:true, zoomControl:false});  
    var osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    var osmAttrib='Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
    var osm = new L.TileLayer(osmUrl, {minZoom: 3, maxZoom: 18, attribution: osmAttrib});
    map.addLayer(osm);
```

To be able to tweak this to your needs, we need to understand how this works. Even if you don't know javascript this should be familiar enough to make modifications to. Let's look at each line individually:

```
    var map = new L.Map('map', { center: new L.LatLng( 19.5429, -155.6659), zoom: 8, attributionControl:true, zoomControl:false});  
```
The line above instantiates a new `L.Map` object. This is an object in javascript memory that contains information about a map. As part of the initialization it identifies the `map` ID, which corresponds to the `<div id="map"... />` HTML element where the map will be rendered
```
    var osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
```
This is just a string that contains a templated line for a tiled map service. The template has placeholders for `s` (subdomain), `z` (zoom level), `x` (x-tile index), and `y` (y-tile index). While `x`, `y`, and `z` are easy enough to guess, the `s` is an optimization for speeding up the webpage. A map tile provider can serve web tiles from multiple sites in order to accelerate the rate at which a client (i.e., your browser) can request and receive tiles.

```
    var osmAttrib='Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
```
This is another string that just prints attribution data.
```
    var osm = new L.TileLayer(osmUrl, {minZoom: 3, maxZoom: 18, attribution: osmAttrib});
```
This is another important `leaflet.js` function that instantiates a type of `Layer` - specifically a `TileLayer` based on the `osmUrl` and other attributes. At this point it has not been added to the `map` object and cannot and has not been rendered.
```
    map.addLayer(osm);
```
This is the final piece of the puzzle. This adds the `osm` `TileLayer` to the `map` object.

Your first task is to change the `getting-started.html` and learn about the interaction of your edits to HTML, javascript, and how it relates to the webpage.

First, change the initial lat/long to `22.05, -159.55` and zoom level to `10` by changing the line that declares `var map`:
```
      var map = new L.Map('map', { center: new L.LatLng( 22.05, -159.55), zoom: 10, attributionControl:true, zoomControl:false});  
```

When you reload `getting-started.html` you should now see the island of Kauai rendered by the terrain tile map service. 

Take a screenshot, making sure the url is visible in the browser screenshot.

Save this as 
- `screencap-osm-kauai.png`

### 4. Try a different tile background
Stamen Maps is a maps and visualization studio that has produced a number of free maps that you can use. See http://maps.stamen.com/#terrain/11/36.3716/-121.7322 for details on how to use the stamen maps in your project. 

Follow the directions on the stamen website to produce two new maps (with screenshots) for `terrain` and `watercolor`. Feel free to use different coordinates/zoom levels. Save these as:
- `screencap-terrain.png`
- `screencap-watercolor.png`

### 5. Add a WMS from geoserver to your Leaflet Map
Next we would like to connect a WMS service containing OSM data you downloaded previously and render it on a leaflet map.

Read the example at https://leafletjs.com/examples/wms/wms.html.

Create a brand new file in the `html` directory named `geoserver.html` and copy the contents of `getting-started.html` as a starting point. You are going to add a new layer based on your own geoserver layer group named `osm:osm`. Note that you will want to update the initial map coordinates, depending on what state you have chosen for your database. Otherwise anybody using your map will have to pan the world to find your OSM WMS data.

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

Save the `geoserver.html` page (make sure it is in the `nginx/html` folder) and open it in your browser. There is a pre-made link for you on the index page of the `Local Address` landing page. You should see the symbology from your WMS after a brief wait. If not, then something went wrong. In that case, open your Developer Tools and look at the `console` and the `network` activity to see if you can debug any errors.

Take a screenshot of your working geoserver.html page and save it as:
- `screencap-leaflet-geoserver-osm.png`

## Epilogue
Congratulations, you are running  a full GIS stack with geospatial backend served by OGC-compliant web services which are consumed by not just your desktop client (QGIS) but also a web client. And to boot, it is all served from a small config file. Even better, you can take this `docker-compose.yml` file and run it _anywhere_ that docker can run. It would be trivial to run this in an environment that facilitated auto-scaling so that you could ramp up from one to hundreds or thousands of copies of your webapp to accomodate a dynamic load.

## Troubleshooting tips
- The Developer Toolbox is your friend!

## Deliverable: Pull Request in `assignment` branch with:
1) screenshot: `screencap-osm-kauai.png`
2) screenshot: `screencap-terrain.png`
3) screenshot: `screencap-watercolor.png`
4) screenshot: `screencap-leaflet-geoserver-osm.png`
5) new file: `html/geoserver.html`
