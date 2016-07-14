# Overview

The Makefile included in this repository has targets to generate TopoJSON files from US Census Tiger Lines shapefiles.

This file requires *ogr2ogr* and *topojson* be installed on the machine. The commands below are examples for installing them on a Mac.

```
brew install gdal
npm install -g topojson
```

### make us.json

The us.json target will generate a merged TopoJSON file for the United States with the following objects:

+ state: state boundaries for the United States (from National Atlas)
+ counties: county boundaries for the Unites States
+ districts: 114th Congressional district boundaries for the Unites States. 

Additionally, the target will create a *us* folder at root with individual TopoJSON files for each object.



### make states/%.json

The states wildcard uses the state FIPS code to generate a merged topojson file for a single state with the following objects:

+ state: The state boundary
+ counties: The county boundaries
+ districts: The 114th Congressional district boundaries
+ senate: State Legislature upper district boundaries
+ house: State Legislature lower district boundaries

Example: `make states/20.json`



### make zipcodes/%.json

The zipcode wildcard uses the state FIPS code to generate a topojson file for a single state with the following object:

+ zips: ZCTA5 boundaries for the state

Example: `make zipcodes/20.json`

**Note:** The ZCTA file is 500 MB and not available by state. Therefore, the minumum and maximum zip codes need to be listed manually and that list exceeded the scope of the project so far. I will add more states when it is required, and will accept pull requests if anyone else wants to contribute.

