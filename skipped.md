
### Georeferencing Web Tiles

**Important update for Fall 2023 -- Skip this Georeferencing Web Tiles section!**
In this section, `cd` back to your home directory in terminal:
```
cd ..
```
The maps you see on the web are composed of many different tiles, each 256- by 256-pixels, scaled to fit the display size. They’re not individually georeferenced, but each fits into a system that allows their relative scale and placement to be derived.


The most common web mapping tiling scheme consists of a a zoom level, an x coordinate, and a y coordinate. Zoom levels typically range from 0 (156,412 meters per pixel, global) to about 19 (about 0.3 meters per pixel—as detailed as the highest-resolution unclassified satellite data). At higher zoom levels, the map is subdivided into two equal vertical and horizontal slices. Every slice is given an x and y coordinate, starting with 0 in the upper-left-hand corner. Mapbox has an excellent and much more detailed description of how web maps work.

This consistent scheme provides a mechanism for GDAL to decode, and the ability to convert web tiles into a georeferenced file. The code to generate a map of the Canyonlands is deceptively simple:
```
gdal_translate -projwin -110.75 39 -109 37.5 -projwin_srs EPSG:4326 -outsize 4096 0 frmt_wms_stamen_terrain_tms.xml canyonlands_terrain_4096.tif
```
It looks just like a normal use of gdal_translate, but instead of pointing to an image, it’s pointing to an XML file (included here):
```
<GDAL_WMS>
<Service name="TMS">
<ServerUrl>http://b.tile.stamen.com/terrain-background/${z}/${x}/${y}.jpg</ServerUrl>
</Service>
<DataWindow>
<UpperLeftX>-20037508.34</UpperLeftX>
<UpperLeftY>20037508.34</UpperLeftY>
<LowerRightX>20037508.34</LowerRightX>
<LowerRightY>-20037508.34</LowerRightY>
<TileLevel>18</TileLevel>
<TileCountX>1</TileCountX>
<TileCountY>1</TileCountY>
<YOrigin>top</YOrigin>
</DataWindow>
<Projection>EPSG:3857</Projection>
<BlockSizeX>256</BlockSizeX>
<BlockSizeY>256</BlockSizeY>
<BandsCount>3</BandsCount>
<ZeroBlockHttpCodes>302</ZeroBlockHttpCodes>
<Cache />
</GDAL_WMS>
```
A full description of the process is in the GDAL Web Map Services documentation, but the basic idea is to open up the XML file in a text editor and point the `<ServerUrl>` line at the map server hosting the tiles you want to download, stitch, and georeference. (I also added a little buffer around the edges with `-projwin -110.75 39 -109 37.5` so my subsequent reprojection step wouldn’t be cut off at the edges.)

There are several examples using different types of map servers in the documentation, but if you are viewing a slippy map you can often right-click (command-click on a mac) on the map and it will give you the option to open the image in a new tab or window — that will give you the URL to paste into `<ServerUrl>`. Replace `/terrain/` with `/watercolor/` to generate stylized maps. You can access Open Street Map tiles by changing the URL to http://tile.openstreetmap.org/ and file format from .jpg to .png:

```
<ServerUrl>http://tile.openstreetmap.org/${z}/${x}/${y}.png</ServerUrl>
```
BTW—Stamen’s map tiles are built on Open Street Map and licensed under creative commons—make sure you follow any licensing requirements for the data you use, and please don’t abuse your access by downloading tens of thousands of tiles.

The final step is to convert the map from Web Mercator to equidistant conic with what should be familiar `gdalwarp` command (although I admit to need to have the documentation open more often then not to make sure I get the syntax right):
```
gdalwarp -t_srs '+proj=eqdc +lat_1=38.025 +lat_2=38.470 +lon_0=-109.875' -te -110.5 37.75 -109.25 38.75 -te_srs EPSG:4326 -ts 1400 0 -r bilinear canyonlands_terrain_4096.tif canyonlands_terrain_eqdc_1400.tif
```
Next, generate a smaller png image:
```
gdal_translate -of PNG -outsize 1400 0 -r bilinear canyonlands_terrain_4096.tif canyonlands_terrain_1400.png
```
Finally, update the `frmt_wms_stamen_terrain_tms.xml` and change `terrain-background` to `watercolor` to allow gdal to draw tiles from a different stamen web service. Re-run the last few commands to create new files named `canyonlands_watercolor_4096.tif` and `canyonlands_watercolor_1400.png` that represent the watercolor versions of the web service.

### Deliverables for this section:
- canyonlands_terrain_1400.png
- canyonlands_watercolor_1400.png

With these tools the wide variety of government and open-source data available, I hope you’ll be able to get started making your own maps. But what if you want to go beyond idealized base maps, and explore a photo-realistic view of the world, or show change over time? That will be the topic of my next post—processing satellite data, including Planet, Landsat, and Sentinel, with GDAL.
