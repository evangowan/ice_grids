#! /bin/bash

mkdir temp

topo=ETOPO2022
ice_model=DATED-2-046
calculated_sea_level="/home/evan/PaleoMIST_2/deform/DATED-2-046_ehgr_rsl.nc"








# remove the extra times in the calculated sea level




all_time=""


min_time=0
time_interval=1000
max_time=30000

values="$(seq ${min_time} ${time_interval} ${max_time} )"

start_index=$(echo "(80000 - ${max_time}) / 500" | bc)
end_index=$(echo "(80000 - ${min_time}) / 500" | bc)

echo ${start_index},${end_index}
ncks -O -d time,${start_index},${end_index},2 ${calculated_sea_level} temp/rsl_a.nc

min_time=32500
time_interval=2500
max_time=80000

values="${values} $(seq ${min_time} ${time_interval} ${max_time} )"
echo ${values}
all_files=""

start_index=$(echo "(80000 - ${max_time}) / 500" | bc)
end_index=$(echo "(80000 - ${min_time}) / 500" | bc)
echo ${start_index},${end_index}
ncks -O -d time,${start_index},${end_index},5 ${calculated_sea_level} temp/rsl_b.nc

cdo -O mergetime temp/rsl_a.nc temp/rsl_b.nc temp/merge_rsl.nc



for time_value in ${values}
do


	gmt xyz2grd ice_temp/${time_value}_temp.txt -R${calculated_sea_level} -Z -fg -Gtemp/${time_value}.nc

	ncap2 -O -s "defdim(\"time\",1);time[time]=-${time_value}.0;time@long_name=\"Time\";time@units=\"years since 1950-01-1;\";time@calendar=\"365_day\"" temp/${time_value}.nc temp/${time_value}_a.nc
	ncecat -O -u time temp/${time_value}_a.nc  temp/${time_value}_b.nc 

	z_name="ice_thickness"
	z_long_name="grounded ice thickness"

	ncrename -O -v z,${z_name}  temp/${time_value}_b.nc 
	ncatted -O -a units,${z_name},o,c,"m" temp/${time_value}_b.nc 
	ncatted -O -a long_name,${z_name},o,c,"${z_long_name}" temp/${time_value}_b.nc 

	all_files="${all_files} temp/${time_value}_b.nc"

done

echo ${all_files}

cdo -O mergetime ${all_files} temp/${ice_model}_thickness.nc

ncatted -O -h -a description,global,m,c,"Ice thickness for reconstruction ${ice_model}"  temp/${ice_model}_thickness.nc

all_files=""
all_files2=""

# the grid is not exactly the same, this fixes it!
gmt grd2xyz ${topo}/${topo}.nc -Z > temp/topo.txt 

gmt xyz2grd temp/topo.txt  -R${calculated_sea_level} -Z -fg -Gtemp/topo.nc


gmt gmtmath temp/${ice_model}_thickness.nc?time --TIME_EPOCH=1950-01-01 --TIME_UNIT=y  = temp/times.txt

for index_val in $(seq 0 50)
do

	time_value=$(awk -v index_val=${index_val} '{if (NR==index_val+1) print $1}' temp/times.txt)
	echo ${time_value}

	gmt grdmath  temp/merge_rsl.nc?z[${index_val}]  temp/topo.nc ADD = temp/deform_topo_${index_val}.nc
	gmt grdmath temp/${ice_model}_thickness.nc?ice_thickness[${index_val}] temp/merge_rsl.nc?z[${index_val}] ADD temp/topo.nc ADD = temp/paleo_topo_${index_val}.nc

	z_name="paleo_topography"
	z_long_name="topography accounting for ice thickness, sea level change and deformation"

	ncrename -O -v ice_thickness,${z_name}  temp/paleo_topo_${index_val}.nc
	ncatted -O -a units,${z_name},o,c,"m" temp/paleo_topo_${index_val}.nc
	ncatted -O -a long_name,${z_name},o,c,"${z_long_name}" temp/paleo_topo_${index_val}.nc

	ncap2 -O -s "defdim(\"time\",1);time[time]=${time_value}.0;time@long_name=\"Time\";time@units=\"years since 1950-01-1;\";time@calendar=\"365_day\"" temp/paleo_topo_${index_val}.nc temp/paleo_topo_${index_val}.nc
	ncecat -O -u time temp/paleo_topo_${index_val}.nc  temp/paleo_topo_${index_val}.nc

	z_name="base_topography"
	z_long_name="deformed base topography excluding ice sheets"

	ncrename -O -v z,${z_name} temp/deform_topo_${index_val}.nc
	ncatted -O -a units,${z_name},o,c,"m" temp/deform_topo_${index_val}.nc
	ncatted -O -a long_name,${z_name},o,c,"${z_long_name}" temp/deform_topo_${index_val}.nc

	ncap2 -O -s "defdim(\"time\",1);time[time]=${time_value}.0;time@long_name=\"Time\";time@units=\"years since 1950-01-1;\";time@calendar=\"365_day\"" temp/deform_topo_${index_val}.nc temp/deform_topo_${index_val}.nc
	ncecat -O -u time temp/deform_topo_${index_val}.nc  temp/deform_topo_${index_val}.nc

	all_files="${all_files} temp/paleo_topo_${index_val}.nc"
	all_files2="${all_files2} temp/deform_topo_${index_val}.nc"


done

	z_name="sea_level"
	z_long_name="calculated sea level excluding topography, relative to present"

	ncrename -O -v z,${z_name} temp/merge_rsl.nc
	ncatted -O -a units,${z_name},o,c,"m" temp/merge_rsl.nc
	ncatted -O -a long_name,${z_name},o,c,"${z_long_name}" temp/merge_rsl.nc

echo ${all_files}

cdo -O mergetime ${all_files} temp/paleo_topo_all.nc
cdo -O mergetime ${all_files2} temp/deform_topo_all.nc


cdo -O merge temp/${ice_model}_thickness.nc temp/merge_rsl.nc temp/deform_topo_all.nc temp/paleo_topo_all.nc temp/${ice_model}_reconstruction.nc


