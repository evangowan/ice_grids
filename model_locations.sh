#!/bin/bash

icesheet_home="${HOME}/icesheet/global_MIS6-1"

# model
north_america_model_number="PaleoMIST_1"
eurasia_model_number="PaleoMIST_1"
antarctica_model_number="Evan_204"
patagonia_model_number="Evan_90"


antarctica_model="${icesheet_home}/Antarctica/plots/${antarctica_model_number}/thickness" # location of netcdf files with thickness
antarctica_projection="${icesheet_home}/Antarctica/projection_info.sh"

eurasia_model="${icesheet_home}/Eurasia/plots/${eurasia_model_number}/thickness"
eurasia_projection="${icesheet_home}/Eurasia/projection_info.sh"


north_america_model="${icesheet_home}/North_America/plots/${north_america_model_number}/thickness"
north_america_projection="${icesheet_home}/North_America/projection_info.sh"

patagonia_model="${icesheet_home}/Patagonia/plots/${patagonia_model_number}/thickness"
patagonia_projection="${icesheet_home}/Patagonia/projection_info.sh"
