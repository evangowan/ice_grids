#! /bin/bash

# This script must be run after running create_selen_input.sh

tegmark_resolution=60
hexagon_file="tegmark/hexagons_${tegmark_resolution}.gmt"
points_file="tegmark/points_${tegmark_resolution}.txt"


# For Lambert azimuthal projection. These parameters cover the entire range of places where North American ice sheets covered, so it shouldn't need to be changed.
# If you do change it, you need to re-run the topography map as well!

center_longitude=-94
center_latitude=60
resolution=5 # grid resolution, in km!


# corner points of the grid (if we don't use this, gmt assumes a global grid, which will be huge!
# west corresponds to the bottom left corner, east corresponds to the top right corner
# probably easiest to pick off the cordinates off Google Earth, in a really zoomed out view
west_latitude=25
west_longitude=-135
east_latitude=58
east_longitude=3

map_width=15c

shift_up="-Y12"

J_options="-JA${center_longitude}/${center_latitude}/${map_width}"
R_options="-R${west_longitude}/${west_latitude}/${east_longitude}/${east_latitude}r"


gmt mapproject  ${hexagon_file}  ${R_options} ${J_options} -F  > hexagon_projected.gmt

gmt mapproject  ${points_file}  ${R_options} ${J_options} -F  > points_projected.txt

./tegmarkgrid ${tegmark_resolution}



x_min=0
x_max=8000000
y_min=0
y_max=6000000



map_width=15c/12c

shift_up="-Y10"

J_options="-JX${map_width}"
R_options="-R${x_min}/${x_max}/${y_min}/${y_max}"



gmt makecpt -CSCM/oslo -T0/5000/250 -I > thick_shades.cpt

gmt begin tegmark_test pdf
  gmt psxy tegmark_hexagon_thickness.gmt  -Bwesn -B2000000   -Cthick_shades.cpt -L  -Wthin,black 
  gmt colorbar -DJBC+w7c/0.5c+h+   -Bxa1000f500+l"Ice Thickness (m)" -G0/4000 -Cthick_shades.cpt
gmt end

