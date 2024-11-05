#! /bin/bash

./grid_creation

x_min=-20
x_max=120
y_min=-20
y_max=120



map_width=15c

shift_up="-Y12"

J_options="-JX${map_width}"
R_options="-R${x_min}/${x_max}/${y_min}/${y_max}"

plot=test.ps

gmt psxy hex_grid.gmt -BWeSn -B20  -K ${R_options} ${J_options} -P -Wthick,black > ${plot}

gmt psxy limits.gmt -O -K -R -J -P -Wthick,red >> ${plot}

gmt psxy points.txt -O  -R -J -P -Sc0.1 -Gblue -Wblue >> ${plot}
