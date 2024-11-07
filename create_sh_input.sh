#! /bin/bash

temp_dir="ice_temp"

rm -R ${temp_dir}

mkdir ${temp_dir}


polygon_file="lat_long_poly.gmt"
points_file="lat_long_points.txt"

time_interval=20000
max_time=20000

source model_locations.sh

# run antarctica

source ${antarctica_projection}



gmt mapproject  ${polygon_file}  ${R_options} ${J_options} -C -F  > sh_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options} -C -F  > points_projected.txt


#for times in $(seq 0 ${time_interval} ${max_time} )
#do
times=20000
	input_file=${antarctica_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./sh_grid

	mv sh_element_thickness.txt >> ${temp_dir}/${times}.txt

#done

exit 0

# run Eurasia

source ${eurasia_projection}

gmt mapproject  ${hexagon_file}  ${R_options} ${J_options} -F  > hexagon_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options} -F  > points_projected.txt

for times in $(seq 0 ${time_interval} ${max_time} )
do

	input_file=${eurasia_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./tegmarkgrid ${tegmark_resolution}

	cat element_thickness.txt >> ${temp_dir}/${times}.txt

done



# run North America

source ${north_america_projection}

gmt mapproject  ${hexagon_file}  ${R_options} ${J_options} -F  > hexagon_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options} -F  > points_projected.txt

for times in $(seq 0 ${time_interval} ${max_time} )
do

	input_file=${north_america_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./tegmarkgrid ${tegmark_resolution}

	cat element_thickness.txt >> ${temp_dir}/${times}.txt

done


# run Patagonia

source ${patagonia_projection}

gmt mapproject  ${hexagon_file}  ${R_options} ${J_options} -F  > hexagon_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options} -F  > points_projected.txt

for times in $(seq 0 ${time_interval} ${max_time} )
do

	input_file=${patagonia_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./tegmarkgrid ${tegmark_resolution}

	cat element_thickness.txt >> ${temp_dir}/${times}.txt

done

./selen_ice_input ${tegmark_resolution} ${max_time} ${time_interval}