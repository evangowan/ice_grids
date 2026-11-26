#!/bin/bash

icesheet_home="${HOME}/icesheet/global_MIS6-1"


run_name=DATED2-runs-01_6
antarctica_model="${icesheet_home}/Antarctica/plots/${run_name}/thickness" # location of netcdf files with thickness
antarctica_topo="${icesheet_home}/Antarctica/topo/Antarctica.nc" # location of modern subglacial topo
antarctica_projection="${icesheet_home}/Antarctica/projection_info.sh"

run_name=DATED2-runs-01_46
eurasia_model="${icesheet_home}/Eurasia/plots/${run_name}/thickness"
eurasia_topo="${icesheet_home}/Eurasia/topo/Eurasia.nc"
eurasia_projection="${icesheet_home}/Eurasia/projection_info.sh"

run_name=DATED2-runs-01_5
north_america_model="${icesheet_home}/North_America/plots/${run_name}/thickness"
north_america_topo="${icesheet_home}/North_America/topo/North_America.nc"
north_america_projection="${icesheet_home}/North_America/projection_info.sh"


run_name=DATED2-runs-01_5
patagonia_model="${icesheet_home}/Patagonia/plots/${run_name}/thickness"
patagonia_topo="${icesheet_home}/Patagonia/topo/Patagonia.nc"
patagonia_projection="${icesheet_home}/Patagonia/projection_info.sh"
