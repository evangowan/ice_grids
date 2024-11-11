#!/bin/bash

name=ETOPO2022
file_location="${HOME}/topo/ETOPO_2022/ETOPO_2022_v1_30s_N90W180_bed.nc"

mkdir ${name}

spacing=0.703125

R_options="-R0.35156/359.64844/-89.64844/89.64844"

gmt grdsample -I${spacing} ${R_options} -nc -rg -G${name}.nc ${file_location}

gmt grd2xyz ${name}.nc > ${name}_a.txt

sort -k2,2nr -k1,1n ${name}_a.txt > ${name}.txt

awk '{print $3}' ${name}.txt > ${name}/topo_base_256
cp lat_long_points.txt ${name}/grid-256.xy
