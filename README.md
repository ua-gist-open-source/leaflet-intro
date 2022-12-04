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
Check out this repo to your computer and perform the following work in a branch named `leaflet`. Deliverables are listed at the bottom.

### 0. Environment setup:
Open your `docker-compose.yml` file and replace the `${REPO_NAME}` string in the volume mappings for the three services: 
`postgres`: 
- `- /workspaces/${REPO_NAME}/postgres_data/data:/var/lib/postgresql/data`
`geoserver`:
- `- /workspaces/${REPO_NAME}/osm-styles:/opt/geoserver/data_dir`
`leaflet`:
- `- /workspaces/${REPO_NAME}/html:/usr/share/nginx/html`

In my case, my workspace repository is named `8-0-leaflet-intro-aaryno`, where the "`aaryno`" part is my github username. Yours will be slightly different but this is how mine would look: 

`postgres`: 
- `- /workspaces/8-0-leaflet-intro-aaryno/postgres_data/data:/var/lib/postgresql/data`
`geoserver`:
- `- /workspaces/8-0-leaflet-intro-aaryno/osm-styles:/opt/geoserver/data_dir`
`leaflet`:
- `- /workspaces/8-0-leaflet-intro-aaryno/html:/usr/share/nginx/html`

After setting up your `docker-compose.yml`, start up your docker services:

```
docker compose up -d
```

Next, Create the OSM database for Hawaii. I created a script that _should_ automatically re-create the database from the previous assignment.
```
./populate_database.sh
```

You can see them running in the Docker Extension for VS Code.

### 1. Getting started with Leaflet:
Refer to the following 
https://leafletjs.com/examples/quick-start/

I have included a starter file in this repository to help you get started that represents the working map up to the quick-start section labeled "Markers, circles and polygons"

- [html/index.html](html/index.html)

Open the `html/index.html` file in your local browser. To do this, click on the `Ports` tab in the VS Code Terminal panel and find Port `80`, which is where the leaflet docker container is running. Open the `Local Address` url in a browser. It will have two links: `getting-started.html` and `geoserver.html`. Click on the `getting-started.html` to open a new page containing a leaflet map.

Confirm the map is visible and interactive. It should be zoomed initially to the big island of Hawaii.

Note that this container is actually just running a small webserver serving files from your `html` directory in this codespace. There is a single file, `index.html`, which is what the web server, nginx, will serve by default if a file path is not given. There is a `getting-started.html` file as well. If you add additional files to the `html` directory they will be accessible from your web browser by appending the filenames to the Local Address url.

### 2. Modify `getting-started.html` for different options.

In VS Code, open the `html/getting-started.html` file. First, modify the url of the tile service. Instead of using `tile.openstreetmap.org`, we will change it to a service in the `tile.stamen.com` domain. We comment out this line:
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
    var osmUrl='https://stamen-tiles-c.a.ssl.fastly.net/terrain/{z}/{x}/{y}@2x.png'
```
Reload the `getting-started.html` and verify that the background map has been changed to a terrain map.

Take a screenshot, making sure the url is visible in the browser screenshot, and save this as `screencap-terrain-hawaii.png`

Next, change the initial lat/long to `22.05, -159.55` and zoom level to `10` by changing the line that declares `var map`:
```
      var map = new L.Map('map', { center: new L.LatLng( 22.05, -159.55), zoom: 10, attributionControl:true, zoomControl:false});  
```

When you reload `getting-started.html` you should now see the island of Kauai rendered by the terrain tile map service. 

Take a screenshot, making sure the url is visible in the browser screenshot, and save this as `screencap-terrain-kauai.png`

### 3. Try a different tile background
Stamen has a few other styles of tile maps we can try out. Let's try `toner`. Change the `osmUrl` value to `'http://stamen-tiles-d.a.ssl.fastly.net/toner/{z}/{x}/{y}@2x.png'` and refresh your `getting-started.html` page to see it in effect. Now reload the page.


### 4. Add a WMS from geoserver to your Leaflet Map
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

Save the `geoserver.html` page and open it in your browser. There is a pre-made link for you on the index page of the `Local Address` landing page. You should see the symbology from your WMS after a brief wait. If not, then something went wrong. In that case, open your Developer Tools and look at the `console` and the `network` activity to see if you can debug any errors.


## Epilogue
Congratulations, you are running  a full GIS stack with geospatial backend served by OGC-compliant web services which are consumed by not just your desktop client (QGIS) but also a web client. And to boot, it is all served from a small config file. Even better, you can take this `docker-compose.yml` file and run it _anywhere_ that docker can run. It would be trivial to run this in an environment that facilitated auto-scaling so that you could ramp up from one to hundreds or thousands of copies of your webapp to accomodate a dynamic load.

## Troubleshooting tips
- The Developer Toolbox is your friend!

## Deliverable: Pull Request in `assignment` branch with:
1) screenshot: `screencap-terrain-hawaii.png`
2) screenshot: `screencap-terrain-kauai.png`
3) screenshot: `screencap-leaflet-geoserver-osm.png`
4) new file: `html/geoserver.html`
