[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/LgPlVbHI)
[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-7f7980b617ed060a017424585567c406b6ee15c891e84e1186181d67ecf80aa0.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=13029606)
# GDAL Intro
## Assignment

The objective of this assignment is to gain experience with `gdal` and some of its tools by working with imagery through a couple tutorials.

### Deliverables
A Pull Request on a branch named `assignment` to be merged with `master` containing the following files:
- CANYrelief1.jpg
- NE1_50M_SR_W_tenth_mollweide_1400.png
- NE1_50M_SR_W_sh60_polarstereo_1400.png
- NE1_50M_SR_W_nh60_polarstereo_1400.png
- screencap_tiles.png
- canyonlands_terrain_1400.png
- canyonlands_watercolor_1400.png

### Background

GDAL (http://www.gdal.org) is a very powerful library and command utility used to read, write, and transform raster and 
vector geospatial data. GDAL's sister project, OGR, is a library and set of utilities that reads, writes, and transforms
vector data. GDAL is an open source project released under the MIT license, allowing re-purposing for commercial use. As 
such, GDAL is used in both open source and commercial projects (e.g., ESRI's suite) for handling raster data.

As an open source project with lots of configuration options, including the ability to link proprietary libraries for
proprietary data formats, installation and configuration can be tricky so in this class we will use a docker container
which has pre-installed the libraries we need. This simplifies use in that it will run the same on a mac, windows, or linux,
but will require a bit more on the command line in order to access the right docker image, mount a volume, and of course 
run the command.

Reference:
- [GDAL Homepage](https://gdal.org/)
- [GDAL Wikipedia](https://en.wikipedia.org/wiki/GDAL)

## Assignment: Part 1 
This is adapted (mostly stolen) from Robert Simmon's tutorial, [A gentle introduction to gdal Part 1](https://medium.com/planet-stories/a-gentle-introduction-to-gdal-part-1-a3253eb96082).

### gdalinfo 
In your terminal window, type:
```
gdalinfo --version
```
There is a shaded relief GeoTiff in this repo we can start with. Enter this in the terminal:
```
gdalinfo CANYrelief1-geo.tif -mm
```
“gdalinfo” runs the eponymous utility program (one of many included with GDAL), “CANYrelief1-geo.tif” is the name of the file you just downloaded, and “-mm” is a command that calculates and displays additional information. After hitting return, you should see a block of text, beginning with:

```
Driver: GTiff/GeoTIFF
```
This indicates that the file is a GeoTIFF, which is a special type of TIFF that stores the information necessary to place each pixel in the image on the surface of the Earth. It’s an incredibly flexible and useful format, and is increasingly by adopted to store more types of data than just images.

Reading further, the next lines of text are:

```
Files: CANYrelief1-geo.tif
Size is 2800, 2800
```
These simply indicate the file name, and the size (in pixels) of the image. Here’s the really important bit:

```
Coordinate System is:
PROJCS["WGS 84 / Pseudo-Mercator",
GEOGCS["WGS 84",
DATUM["WGS_1984",
SPHEROID["WGS 84",6378137,298.257223563,
AUTHORITY["EPSG","7030"]],
AUTHORITY["EPSG","6326"]],
PRIMEM["Greenwich",0,
AUTHORITY["EPSG","8901"]],
UNIT["degree",0.0174532925199433,
AUTHORITY["EPSG","9122"]],
AUTHORITY["EPSG","4326"]],
PROJECTION["Mercator_1SP"],
PARAMETER["central_meridian",0],
PARAMETER["scale_factor",1],
PARAMETER["false_easting",0],
PARAMETER["false_northing",0],
UNIT["metre",1,
AUTHORITY["EPSG","9001"]],
AXIS["X",EAST],
AXIS["Y",NORTH],
EXTENSION["PROJ4","+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs"],
AUTHORITY["EPSG","3857"]]
Origin = (-12249462.599999999627471,4629559.794860946945846)
Pixel Size = (13.284000000000001,-13.285397060378999)
```
This is the information that places this image in the Canyonlands, and specifies the location of each pixel. I’ll get into map projections in my next post, but if you want to learn more the USGS has a nice primer (PDF)—or just read XKCD. The last entry is the pixel size in meters—defined by the “unit” entry further up.

Next up is some generic metadata for the file:
```
Metadata:
  AREA_OR_POINT=Area
Image Structure Metadata:
  INTERLEAVE=PIXEL

Corner Coordinates:
Upper Left  (  579185.000, 4244814.000) (110d 5'37.69"W, 38d20'52.73"N)
Lower Left  (  579185.000, 4213134.000) (110d 5'50.41"W, 38d 3'45.00"N)
Upper Right (  618938.000, 4244814.000) (109d38'20.28"W, 38d20'36.90"N)
Lower Right (  618938.000, 4213134.000) (109d38'39.38"W, 38d 3'29.33"N)
Center      (  599061.500, 4228974.000) (109d52' 6.92"W, 38d12'11.79"N)
Band 1 Block=2650x1 Type=Byte, ColorInterp=Red
Band 2 Block=2650x1 Type=Byte, ColorInterp=Green
Band 3 Block=2650x1 Type=Byte, ColorInterp=Blue
```

The last block of text displayed by gdalinfo shows the corner points of the image in two different units (meters and minutes, degrees, seconds) and finally some information about each band (also called a channel )in the image. Each channel is byte (8-bit) format, there are three bands (red, green, and blue, respectively), and the minimum and maximum values in each band.

That last detail was calculated and displayed because I added “-mm” (min/max) to the command. If you throw in “-stats” you’ll get additional statistics like mean, median, and standard deviation. But be careful, some software (QGIS) may write estimates of these values into the file header and gdalinfo will return the wrong values if you just use “stats”, whereas “-mm” will force statistics to be calculated on the full dataset. Slow but thorough.

### gdal_translate
Now that we have some information about the file, let’s do something useful—resizing the image to a web-friendly 1,400-pixels-wide and saving it as a JPEG—with “gdal_translate”. Enter these commands into the terminal:

```
gdal_translate -of JPEG -co QUALITY=70 -co PROGRESSIVE=ON -outsize 1400 0 -r bilinear CANYrelief1-geo.tif CANYrelief1.jpg
```
You’ll see two lines of text as a result, and have a brand-new file, CANYrelief1.jpg, in the same directory as the TIFF. I specified the file type, size, etc. with the following commands:

```
-of JPEG -co QUALITY=70 -co PROGRESSIVE=ON
```
“-of” sets the output format, in this case JPEG. “-co QUALITY=90” and “-co PROGRESSIVE=ON” are creation options, a series of commands specific to each file type, in this case writing a JPEG with a quality of 90 out of 100 that will load progressively.
```
-outsize 1400 0 -r bilinear
```
These two commands indicate set the output size and interpolation method of the resizing. “-outsize” is set in pixels—x (horizontal) first and y (vertical) second. In this case I set y to zero, so the image kept it’s original aspect ratio. I would have gotten the same results with “-outsize 1400 1400”. “-r” specifies the resampling method, of which GDAL offers a generous selection (nearest, bilinear, cubic, cubicspline, lanczos, average, mode). “Nearest” is the default, but it leaves visible stairsteps so you’ll almost always want to change it. I usually use “bilinear” for satellite imagery since it’s quick and I sharpen as an additional step.

Finally:
```
CANYrelief1-geo.tif CANYrelief1.jpg
```
These are just the input file name and the output file name, respectively (but be careful, gdal_translate will happily overwrite files with no warning).

`gdalinfo` and `gdal_translate` are two of the more straightforward utilities included with GDAL. And, to be honest, there are a thousand ways to convert a TIFF to a JPEG—but not nearly so many are also able to read the headers in a geotiff, translate obscure data formats (if you do data visualization long enough, you’ll run into some special files), or transform a map from one projection to another. Next up is Part 2: Map Projections & gdalwarp, which begins to unlock the power of geospatial data, but requires some familiarity with map projections (spoiler: the Earth isn’t flat).

### Deliverables for this section:
- CANYrelief1.jpg

## Assignment: Part 2
This is adapted (stolen) from Robert Simmon's tutorial, [A gentle introduction to gdal Part 1](https://medium.com/planet-stories/a-gentle-introduction-to-gdal-part-1-a3253eb96082).

To get started, download a global geo-referenced image like Natural Earth I with Shaded Relief and Water (zip file). This is a very nice map of the world with muted colors, based on NASA’s Blue Marble (yeah!) with shading for mountain ranges and the ocean floor.
```
wget https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/50m/raster/NE1_50M_SR_W.zip
unzip NE1_50M_SR_W.zip
```
Once you’ve downloaded and unzipped the TIFF, `cd` to the directory where the geotiff is:
```
cd NE1_50M_SR_W
```
Next, run `gdalinfo NE1_50M_SR_W.tif` to take a look at the metadata, particularly the coordinate system:

```
Coordinate System is:
GEOGCS["WGS 84",
DATUM["WGS_1984",
SPHEROID["WGS 84",6378137,298.257223563,
AUTHORITY["EPSG","7030"]],
AUTHORITY["EPSG","6326"]],
PRIMEM["Greenwich",0],
UNIT["degree",0.0174532925199433],
AUTHORITY["EPSG","4326"]]
```
Of particular note are the units degrees and the line starting with “authority” "EPSG","4326". Unit indicates that each pixel is related to a real-world unit, not just pixels—degrees of latitude and longitude. The bracketed entries after authority (detailed explanation) are a shorthand reference for the map projection—EPSG:4326—which is simply a grid of equal latitude and longitude. This results in a world map that has a 2:1 aspect ratio, and goes from 180˚ west to 180˚ east and 90˚ north to 90˚ south. Of course it’s a bit more complicated than that (in ways I’ll describe later) and the full definition is lengthy, so having a simple 4-digit number makes things easier to type.


Natural Earth I with Shaded Relief and Water. This is in a very common projection with way too many names: Plate Carrée, equirectangular, equidistant cylindrical, simple cylindrical, rectangular, lat-lon, geographic projection, WGS 84, or EPSG:4326. It’s simply an even grid of latitude and longitude, centered at 0˚north 0˚south. Made with Natural Earth.
The file is big (10,800- by 5,400-pixels), so let’s make it a bit smaller using gdal_translate:

```
gdal_translate -r lanczos -tr 0.1 0.1  -co COMPRESS=LZW NE1_50M_SR_W.tif NE1_50M_SR_W_tenth.tif
```
If you read Part 1, most of this should look familiar. The only new bit is `-tr 0.1 0.1`, which sets the target resolution in real-world units. In this case these are degrees of latitude and longitude (as revealed by gdalinfo). Other common options are meters or feet (which you might run into with some projections in the U.S.)

### gdalwarp & the Mercator Projection
Now let’s convert this map from Plate Carrée/rectangular/lat-lon/etc. to Mercator, using another GDAL utility, gdalwarp:

```
gdalwarp -t_srs EPSG:3395 -r lanczos -wo SOURCE_EXTRA=1000 -co COMPRESS=LZW NE1_50M_SR_W_tenth.tif NE1_50M_SR_W_tenth_mercator.tif
```
Breaking down the code: `gdalwarp` invokes the command, while `-t_srs EPSG:3395` sets the target source reference system to `EPSG:3395`, which is the catalog number for Mercator (I’ll go into other ways to do this in a bit). There are a few ways to find these, spatialreference.org is especially helpful because it displays the description of a map projection in several formats.

`-r lanczos` defines the resampling method, with a few more options than `gdal_translate`. Lanczos is slow but high quality. `-wo SOURCE_EXTRA=1000` is an example of a warp option—advanced parameters that determine how the reprojection is calculated. `SOURCE_EXTRA` adds a buffer of pixels around the map as it is reprojected, which helps prevent gaps in the output. Not all reprojections require it, but it doesn’t hurt to add the option to be on the safe side. `-co COMPRESS=LZW` works just the same as it does in `gdal_translate`, and `NE1_50M_SR_W_tenth.tif NE1_50M_SR_W_tenth_mercator.tif` are the input and output filenames, respectively.

Run the command, and you should see a map that looks like this (but slightly larger).

[ Use the Codespaces Explorer to preview ]

An (almost) global map using the Mercator projection. Since the Mercator projection stretches to infinity at the poles, the highest northern and southern latitudes are automatically clipped via mysterious GDAL guesstimates. Made with Natural Earth.
Success!

You may notice that the resulting map stretches the poles. GDAL often behaves unpredictably—in this case it stretches the poles, but add the commands `-te -180 -80 180 80 -te_srs EPSG:4326` to force a different-sized map. It’s often good practice to specifiy output extents, even for a global map, since it can save GDAL some guesswork (which can be slow, or in some cases, end badly).

Unfortunately, the Mercator projection has a glaring error at global scale: the further north or south you go the bigger things get. Greenland appears as big as Africa, while in reality it’s only about 7 percent as large. And I won’t even mention Antarctica, which is absolutely huge despite missing its interior.

So instead of making a map that preserves angles, let’s make a map that preserves area. These are especially useful for thematic maps—i.e. maps that display data geographically, not just geography.

### The Mollweide Projection
Mollweide is one of many equal-area projections, but has the additional nice property of maintaining straight lines of latitude (also called parallels because they run directly east-west and never meet). We could try to re-reproject the Mercator map to Mollweide, but it’s best to minimize the transformations you apply to a dataset, so let’s work with the rectangular map again. Run:

```
gdalwarp -t_srs '+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs' -r lanczos -dstalpha -wo SOURCE_EXTRA=1000 -co COMPRESS=LZW NE1_50M_SR_W_tenth.tif NE1_50M_SR_W_tenth_mollweide.tif
```
(Note: this will generate lots of errors, it’s just GDAL trying to figure out what to do with all the empty space in the corners.)

This is largely the same as the series of commands to make a Mercator map, but I’ve specified the target spatial reference system, `-t_srs` , piece by piece instead of relying on an EPSG code. For reasons I don’t understand, some projections are un-loved by the standards bodies, so they don’t have EPSG codes. Mollweide is one of these, so you need to set the parameters manually, using the proj.4 syntax.

In this case `+proj=moll` sets the projection to Mollweide, which is followed by a string of settings that define parameters like the center of the map (`+lon_0` (try setting this to 175 if you’re upset that New Zealand always gets short shrift on world maps)).

Rather than describing each property, I’ll just recommend that you find the definitions for projections on the Spatial Reference site. It’s got a nice search function, and defines each projection more than a dozen different ways. On the Mollweide page, for example, you’ll see a list with “proj4” on it—click that link to get the full definition: `+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs`. Enclose it in single quotes so it’s parsed correctly.

Finally, I’ve added the option `-dstalpha` so the areas that are (literally) off the map are made transparent, instead of given a fill color (black by default).

To view in codespaces we need a smaller image. Create a jpeg of the same image (this is an assignment deliverable):
```
gdal_translate -of PNG -outsize 1400 0 -r bilinear NE1_50M_SR_W_tenth_mollweide.tif ../NE1_50M_SR_W_tenth_mollweide_1400.png
```

The Mollweide projection, which is equal-area and has the bonus feature of maintaining straight lines of latitude. Made with Natural Earth.
Perfect!

### Deliverables for this section:
- NE1_50M_SR_W_tenth_mollweide_1400.png

### The Polar Stereographic Projection
Well, no, not perfect—every map is a compromise, remember? What if we wanted to focus on the poles? They’re undefined in Mercator, and shunted off to the edges on most other global maps, including Mollweide. Fortunately, there’s a special map projection designed specifically for the Arctic and Antarctic: polar stereographic.

Some pre-processing is required to create a polar stereographic map using GDAL, which also gives me the opportunity to introduce the concept of a virtual dataset (VRT). A vrt is a text file that functions exactly like a georeferenced data file, but it’s much much smaller. Polar stereographic maps become undefined towards the other pole, so the source data needs to be cropped down to the latitude that will become the edge of the map. I’ll again use gdal_translate, but with some new options:

```
gdal_translate -of VRT -projwin -180 -60 180 -90 NE1_50M_SR_W_tenth.tif NE1_50M_SR_W_SH60.vrt
```
Instead of letting gdal_translate write the default GeoTIFF, I’ve used `-of` to specify the output format as a VRT. I’ve then cropped out Antarctica with `-projwin` specifying the boundary in the following format: upper left x, upper left y, lower right x, lower right y (but without the commas). In the Southern Hemisphere upper left longitude is -180˚, upper left latitude is -60˚, lower right longitude is 180˚, and lower right latitude is -90˚ (the South Pole).

With a nice compact (and quick to make) VRT, here’s the command to make a map of Antarctica:

```
gdalwarp -t_srs EPSG:3976 -ts 7200 0 -r near -dstalpha -wo SOURCE_EXTRA=1000 -co COMPRESS=LZW NE1_50M_SR_W_SH60.vrt NE1_50M_SR_W_sh60_polarstereo.tif
```
It starts like the command for Mercator, specifying the target spatial reference system with an EPSG code: EPSG:3976. Then it gets (very slightly) weird. I’ve forced the target size to be 7,200 pixels with `-ts 7200 0` and then set resampling to nearest neighbor with `-r near`. This gets around a nasty issue that was blurring pixels along the +/−180˚ line, at the expense of making the map look pixellated (at least if you zoom in). The rest mirrors the previous commands.

I set the target size to be so much larger than the resolution needed for this post (only 1,400 pixels across) so that I could reduce the resolution with a resampling method that averages pixels—bilinear. Here’s a gdal_translate command to shrink the image and save it as a PNG, a nice lossless compression method (like GIF) that also retains full color (like JPEG) and displays on the Web (this is an assignment deliverable):
```
gdal_translate -of PNG -outsize 1400 0 -r bilinear NE1_50M_SR_W_sh60_polarstereo.tif NE1_50M_SR_W_sh60_polarstereo_1400.png
```
A polar stereographic projection, centered on the South Pole and extending to 60˚ south. Notice how razor-sharp the edge is—that’s the result of the render large then downsize technique, combined with lossless compression. Made with Natural Earth.

Huzzah!

A nice map of Antarctica extending from the South Pole to 60˚ north. Finally, make a similar map of the Northern Hemisphere.

### Deliverables for this section:
- NE1_50M_SR_W_sh60_polarstereo_1400.png
- NE1_50M_SR_W_nh60_polarstereo_1400.png


## Assignment: Part 3
This is adapted (stolen) from Robert Simmon's tutorial, [A Gentle Introduction to GDAL, Part 3: Geodesy & Local Map Projections](https://medium.com/planet-stories/a-gentle-introduction-to-gdal-part-3-geodesy-local-map-projections-794c6ff675ca).

### Crafting Local Maps

We're going to build a map from a very larege dataset. here’s a high-res (1:100,000-scale) version of Natural Earth covering the United States. Not so conveniently, it’s really, really big—4.72 GB big, to be precise. We'll try to download it ourselves here.
First, return to your home directory in Terminal:
```
cd ..
```
Then download the large image, unzip it, and `cd` into the directory it's unzipped to:
```
wget http://www.shadedrelief.com/NE_100m/CONUS_100m_NE_LC_SR_W.zip
unzip CONUS_100m_NE_LC_SR_W.zip
cd CONUS_100m_NE_LC_SR_W
```
Next, subset it to the Canyonlands area:
```
gdalwarp -t_srs '+proj=eqdc +lat_1=38.025 +lat_2=38.470 +lon_0=-109.875' -te -110.5 37.75 -109.25 38.75 -te_srs EPSG:4326 -ts 1400 0 -r bilinear W_CONUS_100m_NE_LC_SR_W.tif canyonlands_eqdc_1400.tif
```
Now we are going to chop it up into 512x512 tiles:
```
mkdir tiles
gdal_retile.py -ps 512 512 -targetDir tiles canyonlands_eqdc_1400.tif
ls -al tiles/
```
Take a screenshot of the terminal window showing the tiles that were created and save it as `screencap_tiles.png`

### Deliverables for this section:
- screencap_tiles.png

### gdal_merge

`gdal_merge` is a helper utility written in Python—it’s not a core part of GDAL. In fact, Frank says he wrote it as a demo (which is why the feature set may seem limited and syntax inconsistent) but people found it useful so it stuck around. And yes, it is useful. Unzip the download, navigate to the natural_earth_100k_canyonlands directory in your command line, and run the following command:
```
gdal_merge.py -o ../canyonlands_merged.tif tiles/*.tif
```
That’s it. `gdal_merge.py` invokes the script, `-o canyonlands_merged.tif` specifies the name of the output file, and `*.tif` is a wildcard that opens up every file in the directory ending with .tif. What `gdal_merge` doesn’t do is any type of reprojection (but it can crop with `-ul_lr` and resize with `-ps` ). So the output file is Web Mercator, just like the input files. Equidistant conic is more appropriate for this region, so use the same gdalwarp command as before (with one change) to reproject the data:

```
gdalwarp -t_srs '+proj=eqdc +lat_1=38.025 +lat_2=38.470 +lon_0=-109.875' -ts 1400 0 -r bilinear -dstalpha canyonlands_merged.tif NE1_HR_LC_SR_W_canyonlands_ne_eqdc_1400.tif
```

I’ve omitted the `te` and `te_srs` options—`gdalwarp` is smart and matches the extents of the output file to the input file, which can be convenient, and results in the subtle cuve along the edges of the map above. To match the boundary of the original (blurry) map, use:

```
gdalwarp -t_srs '+proj=eqdc +lat_1=38.025 +lat_2=38.470 +lon_0=-109.875' -te -110.5 37.75 -109.25 38.75 -te_srs EPSG:4326 -ts 1400 0 -r bilinear canyonlands_merged.tif canyonlands_ne_eqdc_te_1400.tif
```

Looking carefully, it’s evident that even this map isn’t quite detailed enough to display at this size—it needs a slightly higher-resoluton data source. In the not-so-distant past, you’d probably be limited to 7.5 minute USGS topographic maps (or their international equivalents), or custom made maps for specific locations (like U.S. national park maps). But in the past decade or so there’s been an explosion of mapping on the web, both commercial (Google Maps, MapBox) and open-source (Open Street Map). Typically they’re limited to display in a browser, or on a mobile device (that’s what these maps are made for, after all).

## Deliverables
- CANYrelief1.jpg
- NE1_50M_SR_W_tenth_mollweide_1400.png
- NE1_50M_SR_W_sh60_polarstereo_1400.png
- NE1_50M_SR_W_nh60_polarstereo_1400.png
- screencap_tiles.png
