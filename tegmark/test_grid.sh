#! /bin/bash

# controls size of the hexagon shapes
resolution=60

./icosahedron ${resolution}




./hex_grid ${resolution}


sort --numeric-sort  -k 2,2n -k 1,1n  points.txt > points_sorted.txt

./formatted_files ${resolution}

cp -f points_sorted.txt points_${resolution}.txt


#plot="hemisphere.ps"
#gmt pscoast -Rg -JA280/30/3.5i -Bg -Dc -A1000 -Ggrey -P -K  > ${plot}

#gmt psxy points.txt -J -R -K -O -P -Sc0.01 -Gred -Wred >> ${plot}
#gmt psxy hexagons.gmt -R -J -O -K -P -Wthinnest,blue -L >> ${plot}
#gmt psxy points.txt -R -J -O -P -SE- -Wthinnest,green  >> ${plot}

plot=test_plot_${resolution}.ps
gmt pscoast -JA-44.62/60.62/15c -R-49.54/58.43/-40.39/62.95r -Bewns -Di -A1000 -Ggrey -P -K > ${plot}

gmt psxy points_${resolution}.txt -J -R -K -O -P -Sc0.1 -Gred -Wred >> ${plot}
gmt psxy hexagons_${resolution}.gmt -R -J -O -K -P -Wthinnest,blue -L >> ${plot}
gmt psxy points_${resolution}.txt -R -J -O -P -SE- -Wthinnest,green  >> ${plot}
