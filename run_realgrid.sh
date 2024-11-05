#! /bin/bash

input_file=21000.nc

gmt grdconvert ${input_file} -Gtemp.bin=bf

gmt grdinfo -C temp.bin=bf | sed 's/\t/\n/g' > file_info.txt

./realgrid 50000


x_min=0
x_max=8000000
y_min=0
y_max=6000000



map_width=15c/12c

shift_up="-Y10"

J_options="-JX${map_width}"
R_options="-R${x_min}/${x_max}/${y_min}/${y_max}"

plot=real_test.ps

gmt makecpt -Cwysiwyg -T0/4000/50 -I > thick_shades.cpt

gmt psxy real_hexagon_thickness.gmt ${shift_up} -BWeSn -B2000000  -K ${R_options} ${J_options} -Cthick_shades.cpt -L -P -Wthin,black > ${plot}

#gmt psxy limits.gmt -O -R -J -P -Wthick,red >> ${plot}


gmt psscale -X-1 -Y-3.5 -Dx9c/2c/9c/0.5ch -P -O -Bx1000f500+l"Ice Thickness (m)" --FONT_LABEL=14p -Cthick_shades.cpt -V  >> $plot

exit 0

x_min=5960000
x_max=6070000
y_min=750000
y_max=860000



map_width=15c

shift_up="-Y12"

J_options="-JX${map_width}"
R_options="-R${x_min}/${x_max}/${y_min}/${y_max}"

gmt makecpt -Cjet -T0/1/0.01 > ratio_shades.cpt

plot="overlap_test.ps"

gmt psxy fort.667 -BWeSn -B50000  -K ${R_options} ${J_options} -Cratio_shades.cpt -L -P -Wthick,black > ${plot}

gmt psxy fort.668 -O -R -J -P -K -W4p,grey -L >> ${plot}

gmt psxy fort.666 -O -R -J -P -Wthick,red -L >> ${plot}
