.PRECIOUS: census/%.shp

states = na/states.shp
counties = census/COUNTY/tl_2015_us_county.shp
districts = census/CD/tl_2015_us_cd114.shp
zipcodes = census/ZCTA5/tl_2015_us_zcta510.shp
national = $(states) $(counties) $(districts)

help:
	@echo "View the README.md file for help"

#
# Download and create Shapefiles
#

census/%.shp:
	mkdir -p $(dir $@) tmp
	curl -o tmp/$(notdir $*).zip http://www2.census.gov/geo/tiger/TIGER2015/$*.zip
	unzip tmp/$(notdir $*).zip -d $(dir $@)

na/statesp010g.shp:
	mkdir -p na tmp
	curl -o tmp/$(notdir).tar.gz http://dds.cr.usgs.gov/pub/data/nationalatlas/statesp010g.shp_nt00938.tar.gz
	tar -xzvf tmp/$(notdir).tar.gz -C na

na/states.shp: na/statesp010g.shp
	ogr2ogr -where 'TYPE = "Land"' na/states.shp na/statesp010g.shp


#
# Topojson outputs
# Note: the states/%.json target is looking for a FIPS code for a state
#

us.json: $(national)
	mkdir -p us
	topojson -o us/states.json --id-property STATE_FIPS -p name=NAME,usps=STATE_ABBR -s 2e-7 -- states=$(states)
	topojson -o us/counties.json --id-property GEOID -p name=NAME,sfp=STATEFP,cfp=COUNTYFP -s 2e-6 -- counties=$(counties)
	topojson -o us/cd114.json --id-property GEOID -p name=NAMELSAD,sfp=STATEFP,cdfp=CD114FP -s 2e-6 -- districts=$(districts)
	topojson -o us.json --width 900 --height 500 --projection 'd3.geo.albersUsa()' --margin 10 -p -- us/states.json us/counties.json us/cd114.json
 
states/%.json: clean $(national) census/SLDL/tl_2015_%_sldl.shp census/SLDU/tl_2015_%_sldu.shp
	mkdir -p $(dir $@) tmp
	ogr2ogr -where "STATE_FIPS='$*'" tmp/state.shp $(states)
	ogr2ogr -where "STATEFP='$*'" tmp/county.shp $(counties)
	ogr2ogr -where "STATEFP='$*'" tmp/cd114.shp $(districts)
	topojson -o tmp/$*.state.json --id-property GEOID -p name=NAME,usps=STATE_ABBR -s 2e-7 -- state=tmp/state.shp
	topojson -o tmp/$*.counties.json --id-property GEOID -p name=NAME,sfp=STATEFP,cfp=COUNTYFP -s 2e-7 -- counties=tmp/county.shp
	topojson -o tmp/$*.districts.json --id-property GEOID -p name=NAMELSAD,sfp=STATEFP,cdfp=CD114FP -s 2e-7 -- districts=tmp/cd114.shp
	topojson -o tmp/$*.senate.json --id-property GEOID -p name=NAMELSAD,sfp=STATEFP,did=SLDUST -s 2e-7 -- senate=census/SLDU/tl_2015_$*_sldu.shp
	topojson -o tmp/$*.house.json --id-property GEOID -p name=NAMELSAD,sfp=STATEFP,did=SLDLST -s 2e-7 -- house=census/SLDL/tl_2015_$*_sldl.shp
	topojson -o $@ --width 400 --height 300 --projection 'd3.geo.mercator()' --margin 10 -p -- tmp/$*.state.json tmp/$*.counties.json tmp/$*.districts.json tmp/$*.senate.json tmp/$*.house.json

zipcodes/%.json: $(zipcodes)
	mkdir -p $(dir $@) tmp
	ogr2ogr -where $(zipcodes[$*]) tmp/zips.shp $(zipcodes)
	topojson -o $@ --id-property GEOID10 -s 2e-7 --width 400 --height 300 --projection 'd3.geo.mercator()' --margin 10 -- zips=tmp/zips.shp

#
# Clean
#

clean: 
	rm -f tmp/state.* tmp/county.* tmp/cd114.*

#
# Zip codes
#

zipcodes[20] = "GEOID10 >= '66002' and GEOID10 <= '67954'"
zipcodes[29] = "GEOID10 >= '63001' and GEOID10 <= '65899'"
