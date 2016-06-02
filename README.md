# Overview

The Makefile included in this repository has targets to generate TopoJSON files from US Census Tiger Lines shapefiles.

This file requires *ogr2ogr* and *topojson* be installed on the machine. The commands below are examples for installing them on a Mac.

```
brew install gdal
npm install -g topojson
```

## make us.json

The us.json target will generate a merged TopoJSON file for the United States with the following objects:

+ state: state boundaries for the United States
+ counties: county boundaries for the Unites States
+ districts: 114th Congressional district boundaries for the Unites States. 

Additionally, the target will create a *us* folder at root with individual TopoJSON files for each object.

## make states/%.json

The states wildcard will generate a merged topojson file for a single state with the following objects:

+ state: The state boundary
+ counties: The county boundaries
+ districts: The 114th Congressional district boundaries
+ senate: State Legislature upper district boundaries
+ house: State Legislature lower district boundaries

## make ks.json

The Kansas target will generate the states/20.json file, and append the following objects:

+ zips: ZCTA5 boundaries for the state

## make mo.json

The Missouri target will generate the states/29.json file, and append the following objects:

+ zips: ZCTA5 boundaries for the state

### A note on individual state files and ZCTA5 boundaries

The zipcode file on the US Census site is 500 MB and is not available by state. Therefore, zip codes need to be manually pulled before being merged with the state file using individual targets. The scope of this project stopped with the two states required, so I have not created those targets. I would be happy to merge a pull request if anyone else uses this repository.
