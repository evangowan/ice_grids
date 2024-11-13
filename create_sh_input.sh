#! /bin/bash

# This needs to be run after running the program './define_sh_grid 512'
# This needs to be run after running the script topo_ETOPO2022.sh (or if you change it, a different topo script)
topo=ETOPO2022
ice_model=PALEOMIST_1

temp_dir="ice_temp"



rm -R ${temp_dir}

mkdir ${temp_dir}

rm -R ${ice_model}
mkdir ${ice_model}

polygon_file="lat_long_poly.gmt"
points_file="lat_long_points.txt"

time_interval=2500
max_time=80000

#source model_locations.sh
source model_locations_paleomist.sh

# run antarctica

source ${antarctica_projection}



gmt mapproject  ${polygon_file}  ${R_options} ${J_options} -C -F  > sh_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options} -C -F  > points_projected.txt


for times in $(seq 0 ${time_interval} ${max_time} )
do

	input_file=${antarctica_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./sh_grid



	mv sh_element_thickness.txt ${temp_dir}/${times}_list.txt

done



source ${eurasia_projection}

gmt mapproject  ${polygon_file}  ${R_options} ${J_options}  -F  > sh_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options}  -F  > points_projected.txt

for times in $(seq 0 ${time_interval} ${max_time} )
do

	input_file=${eurasia_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./sh_grid

	 paste --delimiters ' ' sh_element_thickness.txt ${temp_dir}/${times}_list.txt > temp.txt
     mv temp.txt ${temp_dir}/${times}_list.txt
done



# run North America

source ${north_america_projection}

gmt mapproject  ${polygon_file}  ${R_options} ${J_options}  -F  > sh_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options}  -F  > points_projected.txt

for times in $(seq 0 ${time_interval} ${max_time} )
do

	input_file=${north_america_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./sh_grid

	 paste --delimiters ' ' sh_element_thickness.txt ${temp_dir}/${times}_list.txt > temp.txt
     mv temp.txt ${temp_dir}/${times}_list.txt

done


# run Patagonia

source ${patagonia_projection}

gmt mapproject  ${polygon_file}  ${R_options} ${J_options}  -F  > sh_projected.gmt
gmt mapproject  ${points_file}  ${R_options} ${J_options}  -F  > points_projected.txt

for times in $(seq 0 ${time_interval} ${max_time} )
do

	input_file=${patagonia_model}/${times}.nc

	gmt grdconvert ${input_file} -Gtemp.bin=bf

	gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

	./sh_grid

	 paste --delimiters ' ' sh_element_thickness.txt ${temp_dir}/${times}_list.txt > temp.txt
     mv temp.txt ${temp_dir}/${times}_list.txt

done

for times in  $(seq 0 ${time_interval} ${max_time} )
do
	awk '{print $1 + $2 + $3 + $4}' ${temp_dir}/${times}_list.txt > ${temp_dir}/${times}_temp.txt
done

# append the ice thickness at time zero to the topography file for consistency

# create intermediate times for Paleomist
time_interval_large=5000
for top_time in $(seq ${max_time} -${time_interval_large} ${time_interval_large})
do

	middle_time=$(echo "${top_time} - ${time_interval}" | bc)
	low_time=$(echo "${top_time} - ${time_interval_large}" | bc)


	paste --delimiters ' '  ${temp_dir}/${top_time}_temp.txt ${temp_dir}/${middle_time}_temp.txt > temp.txt

	time_intermediate=$(echo "${top_time} - 1000" | bc)

#	echo ${time_intermediate}
	awk '{print $1 - 2/5*($1-$2)}' temp.txt > ${temp_dir}/${time_intermediate}_temp.txt
#	paste --delimiters ' ' ${temp_dir}/${top_time}_temp.txt ${temp_dir}/${time_intermediate}_temp.txt > test_${top_time}_paste.txt
	time_intermediate=$(echo "${top_time} - 2000" | bc)

#	echo ${time_intermediate}
	awk '{print $1 - 4/5*($1-$2)}' temp.txt > ${temp_dir}/${time_intermediate}_temp.txt

#	paste --delimiters ' ' test_${top_time}_paste.txt ${temp_dir}/${time_intermediate}_temp.txt > Temp_test_${top_time}_paste.txt
#    mv Temp_test_${top_time}_paste.txt test_${top_time}_paste.txt

#	paste --delimiters ' ' test_${top_time}_paste.txt ${temp_dir}/${middle_time}_temp.txt > Temp_test_${top_time}_paste.txt
#    mv Temp_test_${top_time}_paste.txt test_${top_time}_paste.txt

	paste --delimiters ' '  ${temp_dir}/${middle_time}_temp.txt ${temp_dir}/${low_time}_temp.txt  > temp.txt

	time_intermediate=$(echo "${middle_time} - 500" | bc)
#	echo ${time_intermediate}
	awk '{print $1 - 1/5*($1-$2)}' temp.txt > ${temp_dir}/${time_intermediate}_temp.txt
#	paste --delimiters ' ' ${temp_dir}/${middle_time}_temp.txt ${temp_dir}/${time_intermediate}_temp.txt > test_${middle_time}_paste.txt
	time_intermediate=$(echo "${middle_time} - 1500" | bc)
#	echo ${time_intermediate}
	awk '{print $1 - 3/5*($1-$2)}' temp.txt > ${temp_dir}/${time_intermediate}_temp.txt

#	paste --delimiters ' ' test_${middle_time}_paste.txt ${temp_dir}/${time_intermediate}_temp.txt > TEMP_test_${middle_time}_paste.txt
#	mv TEMP_test_${middle_time}_paste.txt test_${middle_time}_paste.txt
#	paste --delimiters ' ' test_${middle_time}_paste.txt ${temp_dir}/${low_time}_temp.txt > TEMP_test_${middle_time}_paste.txt
#	mv TEMP_test_${middle_time}_paste.txt test_${middle_time}_paste.txt
done

paste ${temp_dir}/0_temp.txt ${topo}/topo_base_256 > ${topo}/topo_temp.txt

awk '{print $1 + $2}' ${topo}/topo_temp.txt > ${topo}/topo-256

last_time=0
for times in $(seq ${max_time} -1000 0 )
do

# for now, I need to set this up to thousands of years.

#    if [ $times -lt 10 ]
#	then
#		time_append=00000$times
#	elif [ $times -lt 100 ]
#	then
#		time_append=0000$times
#	elif [ $times -lt 1000 ]
#	then
#		time_append=000$times
#	elif [ $times -lt 10000 ]
#	then
#		time_append=00$times
#	elif [ $times -lt 100000 ]
#	then
#		time_append=0$times
#	else
#		time_append=$times
#	fi

	time_thousand=$(echo ${times} | awk '{print $1/1000}')
    if [ $time_thousand -lt 10 ]
	then

		time_thousand=0${time_thousand}
	fi



	paste --delimiters ' '  ${temp_dir}/${times}_temp.txt ${temp_dir}/${last_time}_temp.txt > temp.txt

	awk '{print $2 - $1}' temp.txt > ${ice_model}/${ice_model}_${time_thousand}

	last_time=${times}


done
