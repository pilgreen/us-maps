.PRECIOUS: census/%.shp

states = na/states.shp
counties = census/COUNTY/tl_2016_us_county.shp
cd = census/CD/tl_2016_us_cd115.shp
zipcodes = census/ZCTA5/tl_2016_us_zcta510.shp
national = $(states) $(cd) $(counties)

projection?=d3.geo.mercator()

help:
	@echo "View the README.md file for help"

#
# Download and create Shapefiles
#

tmp/%.zip:
	mkdir -p tmp
	curl -o tmp/$(notdir $*).zip http://www2.census.gov/geo/tiger/TIGER2016/$*.zip

census/%.shp: tmp/%.zip
	if [ -a tmp/$(notdir $*).zip ]; then unzip tmp/$(notdir $*).zip -d $(dir $@); fi;

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
	topojson -o us/cd.json --id-property GEOID -s 2e-6 -- cd=$(cd)
	topojson -o us/counties.json --id-property GEOID -p name=NAME -s 2e-6 -- counties=$(counties)
	topojson -o us.json --width 960 --height 500 --projection 'd3.geo.albersUsa()' -p -- us/states.json us/cd.json us/counties.json

states/%.json: cleanstate $(states) $(cd) $(counties) census/SLDL/tl_2016_%_sldl.shp census/SLDU/tl_2016_%_sldu.shp
	mkdir -p $(dir $@) tmp
	ogr2ogr -where "STATE_FIPS='$*'" tmp/state.shp $(states)
	ogr2ogr -where "STATEFP='$*'" tmp/cd.shp $(cd)
	ogr2ogr -where "STATEFP='$*'" tmp/county.shp $(counties)
	topojson -o tmp/$*.state.json --id-property STATE_FIPS -p name=NAME,usps=STATE_ABBR -s 2e-7 -- state=tmp/state.shp
	topojson -o tmp/$*.cd.json --id-property GEOID -s 2e-7 -- cd=tmp/cd.shp
	topojson -o tmp/$*.counties.json --id-property GEOID -p name=NAME -s 2e-7 -- counties=tmp/county.shp
	topojson -o tmp/$*.senate.json --id-property SLDUST -s 2e-7 -- senate=census/SLDU/tl_2016_$*_sldu.shp
	# Nebraska abolished their State House of Representatives
ifeq ($*, 31)
	topojson -o $@ --width 400 --height 300 --projection '$(projection)' -p -- tmp/$*.state.json tmp/$*.counties.json tmp/$*.cd.json tmp/$*.senate.json
else
	topojson -o tmp/$*.house.json --id-property SLDLST -s 2e-7 -- house=census/SLDL/tl_2016_$*_sldl.shp
	topojson -o $@ --width 400 --height 300 --projection '$(projection)' -p -- tmp/$*.state.json tmp/$*.counties.json tmp/$*.cd.json tmp/$*.senate.json tmp/$*.house.json
endif

zipcodes/%.json: $(zipcodes)
	mkdir -p $(dir $@) tmp
	ogr2ogr -where $(zipcodes[$*]) tmp/zips.shp $(zipcodes)
	topojson -o $@ --id-property GEOID10 -s 2e-7 --width 400 --height 300 --projection '$(projection)' -- zips=tmp/zips.shp

#
# Clean
#

cleanstate: 
	rm -f tmp/state.* tmp/county.* tmp/cd.*

clean:
	rm -rf tmp census na

#
# Zip codes
#

zipcodes[20] = "GEOID10 >= '66002' and GEOID10 <= '67954'"
zipcodes[29] = "GEOID10 >= '63001' and GEOID10 <= '65899'"
