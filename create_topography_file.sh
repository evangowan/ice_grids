#! /bin/bash

rm -r temp/

mkdir temp



grid_resolution=5000 # in meters

map_plot_width=15

resolution=60

hexagon_file=tegmark/hexagons_${resolution}.gmt

topography_name=Rtopo2.0.4

topography_path="/home/evan/topo/rtopo_2.0.4/bed_topography.nc"

out_file=${topography_name}-R${resolution}.px

rm ${out_file}

gmt convert ${hexagon_file} -Dtemp/%d.gmt+o1

points_file="tegmark/points_${resolution}.txt"

number_pixels=$(wc -l < ${points_file})

echo ${number_pixels}

for line_number in $(seq 1 ${number_pixels})
do

echo ${line_number}

pixel_line="$(awk -v line_number=${line_number} '{if (NR == line_number) print $0}' ${points_file})"

center_longitude=$(echo ${pixel_line} | awk '{print $1}')
center_latitude=$(echo ${pixel_line} | awk '{print $2}')

diameter=$(echo ${pixel_line} | awk '{print $3}')

J_main="-JA${center_longitude}/${center_latitude}/${map_plot_width}c"





R_main=$(python3 R_value.py ${center_longitude} ${center_latitude} ${diameter})


gmt mapproject temp/${line_number}.gmt -Fe ${R_main} ${J_main} > temp/projected_polygon.gmt

echo ">" > temp/densified_projected_polygon.gmt
python3 densify.py  temp/projected_polygon.gmt ${grid_resolution} >> temp/densified_projected_polygon.gmt
gmt mapproject temp/densified_projected_polygon.gmt -I -Fe ${R_main} ${J_main} > temp/densified_polygon.gmt

#gmt grdcut ${topography_path} -Gtemp/cut_grid.nc -S${center_longitude}/${center_latitude}/${diameter}k ${J_main} ${R_main}
gmt grdcut ${topography_path} -Gtemp/cut_grid.nc -Ftemp/densified_polygon.gmt+c ${J_main} 


#gmt grdproject temp/cut_grid.nc ${J_main} -D${grid_resolution} -Fe ${R_main} -Gtemp/projected_grid.nc

gmt grdproject temp/cut_grid.nc ${J_main} -D${grid_resolution} -Fe ${R_main} -Gtemp/projected_grid.nc


gmt grdmath temp/projected_grid.nc ISNAN 0 EQ SUM = temp/valid.nc
gmt grdmath temp/projected_grid.nc SUM temp/valid.nc DIV = temp/elev.nc

gmt grdtrack << END_CAT -Gtemp/elev.nc > temp/elev_temp.txt
0 0
END_CAT

elev=$(awk --field-separator='\t' '{print $3}' temp/elev_temp.txt )

echo ${center_longitude} ${center_latitude} ${elev} >> ${out_file}

#plot=temp/test.ps
#gmt psxy << END_CAT ${J_main} ${R_main} -Bewns -K -P -Sc0.1 -Gred -Wred > ${plot}
#${center_longitude} ${center_latitude}
#END_CAT

#gmt psxy temp/${line_number}.gmt -R -J -O -K -P -Wthinnest,blue -L >> ${plot}
#gmt psxy << END_CAT -R -J -O -P -SE- -Wthinnest,green  >> ${plot}
#${center_longitude} ${center_latitude} ${diameter}
#END_CAT

done
