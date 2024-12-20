#! /bin/bash

# in this version, I remove the second last time step so that the eustatic sea level matches the ice sheet history. This is required
# because of the way that Selen handles the loading and making sea level zero at time zero. 

temp_dir="ice_temp"

rm -R ${temp_dir}

mkdir ${temp_dir}

tegmark_resolution=60
hexagon_file="tegmark/hexagons_${tegmark_resolution}.gmt"
points_file="tegmark/points_${tegmark_resolution}.txt"

time_interval=2500
max_time=80000

# model
north_america_model_number="Evan_68"
eurasia_model_number="Evan_67"
antarctica_model_number="Evan_64"
patagonia_model_number="Evan_65"


antarctica_model="${HOME}/icesheet/github/global/Antarctica/plots/${antarctica_model_number}/thickness" # location of netcdf files with thickness
antarctica_projection="${HOME}/icesheet/github/global/Antarctica/projection_info.sh"

eurasia_model="${HOME}/icesheet/github/global/Eurasia/plots/${eurasia_model_number}/thickness"
eurasia_projection="${HOME}/icesheet/github/global/Eurasia/projection_info.sh"


north_america_model="${HOME}/icesheet/github/global/North_America/plots/${north_america_model_number}/thickness"
north_america_projection="${HOME}/icesheet/github/global/North_America/projection_info.sh"

patagonia_model="${HOME}/icesheet/github/global/Patagonia/plots/${patagonia_model_number}/thickness"
patagonia_projection="${HOME}/icesheet/github/global/Patagonia/projection_info.sh"

# run antarctica

source ${antarctica_projection}



gmt mapproject  ${hexagon_file}  ${R_options} ${J_options} -C -F  > hexagon_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options} -C -F  > points_projected.txt


for times in $(seq 0 ${time_interval} ${max_time} )
do

	input_file=${antarctica_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./tegmarkgrid ${tegmark_resolution}

	cat element_thickness.txt >> ${temp_dir}/${times}.txt

done

#./selen_ice_input ${tegmark_resolution} ${max_time} ${time_interval}

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

# remove the second last time

rm ${temp_dir}/${time_interval}.txt

max_time_more=$(echo ${max_time}+${time_interval} | bc)

# add a final time step that is identical to the last time

cp -f ${temp_dir}/${max_time}.txt ${temp_dir}/${max_time_more}.txt

for times in $(seq ${time_interval} ${time_interval} ${max_time} )
do

	time_shift=$(echo ${times}+${time_interval} | bc)

	mv -f ${temp_dir}/${time_shift}.txt ${temp_dir}/${times}.txt


done

./selen_ice_input ${tegmark_resolution} ${max_time} ${time_interval}
