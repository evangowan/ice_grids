program fakegrid

	use hexagon_grid
	use overlapping_polygon

	implicit none

	integer, parameter :: grid_dimensions = 101, middle = 50, overlap_size = 50, out_unit = 60
	character(len=150), parameter :: out_file = "hexagon_thickness.gmt"

	double precision, dimension(grid_dimensions,grid_dimensions) :: ice_grid

	
	type(polygon_point), dimension(4) :: grid_cell
	type(polygon_point), dimension(overlap_size) ::overlap_polygon

	double precision, parameter :: g = 9.81, rho_ice = 910.0, L=50000.0, grid_length = 1000, tau_o = 50000.0
  	double precision :: x_min_grid, x_max_grid, y_min_grid, y_max_grid, hexagon_radius, hexagon_area
	double precision :: distance, inner_part
	double precision :: hex_x_min, hex_x_max, hex_y_min, hex_y_max, grid_spacing

  	double precision :: x_min_local, x_max_local, y_min_local, y_max_local, area, area_ratio, biggest, smallest
	integer :: counter1, counter2, hex_counter, overlap_point_count
	integer :: x_counter_start, x_counter_end, y_counter_start, y_counter_end
	logical :: warning

      grid_spacing = 1.0

	do counter1 = 1, 101, 1
		do counter2 = 1, 101, 1

			distance = sqrt((dble(middle - counter1))**2 +(dble(middle - counter2))**2) * grid_length

			inner_part = 2.0*tau_o / (rho_ice * g) * (L-distance)
			if(2.0*tau_o / (rho_ice * g) * (L-distance) > 0) THEN
				ice_grid(counter1, counter2) = sqrt(inner_part)
			else
				ice_grid(counter1, counter2) = 0.0
			endif

			write(555,*) (counter1-1), counter2-1, ice_grid(counter1,counter2)
		end do
	end do

  	x_min_grid = 0.
	x_max_grid = 100.
	y_min_grid = 0.
	y_max_grid = 100.
	hexagon_radius = 2.0

	call definine_grid(x_min_grid, x_max_grid, y_min_grid, y_max_grid, hexagon_radius)

	open(unit=out_unit, file=out_file, access="sequential", form="formatted", status="replace")

	biggest = 0.
	smallest = 9999999.

	do hex_counter = 1, number_hexagons
!		write(6,*) "hexagon: ", hex_counter
		call polygon_extremes(hexagon(hex_counter,:),hexagon_points,hex_x_min, hex_x_max, hex_y_min, hex_y_max)

		! assume that the grid is cell centered

		x_min_local = dble(floor(hex_x_min/grid_spacing)*grid_spacing)
		y_min_local = dble(floor(hex_y_min/grid_spacing)*grid_spacing)

		x_max_local = dble(ceiling(hex_x_max/grid_spacing)*grid_spacing)
		y_max_local = dble(ceiling(hex_y_max/grid_spacing)*grid_spacing)


		x_counter_start = nint(x_min_local / grid_spacing) 
		x_counter_end = nint(x_max_local / grid_spacing) 
		y_counter_start = nint(y_min_local / grid_spacing) 
		y_counter_end = nint(y_max_local / grid_spacing) 

		! lazy hack for now
		if(x_counter_start < 1) THEN
			x_counter_start = 1
		endif

		if(y_counter_start < 1) THEN
			y_counter_start = 1
		endif
		
		if(x_counter_end > 101) THEN
			x_counter_end = 101
		endif
		if(y_counter_end > 101) THEN
			y_counter_end = 101
		endif

		if((x_counter_end < x_counter_start) .or. y_counter_end < y_counter_start) THEN
			hexagon_thickness(hex_counter) = 0.0
			cycle
		end if

		hexagon_area = polygon_area(hexagon(hex_counter,:),hexagon_points)
		call print_polygon(hexagon(hex_counter,:), hexagon_points, 0.d0, 666)
		do counter1 = x_counter_start, x_counter_end, 1
			do counter2 = y_counter_start, y_counter_end, 1

!				write(6,*) ">>>>", (counter1 - x_counter_start) * (y_counter_end - y_counter_start) +&
!						 (counter2 - y_counter_start) + 1

				! create grid cell polygon

				grid_cell(1)%x = dble(counter1) - grid_spacing / 2.0
				grid_cell(1)%y = dble(counter2) - grid_spacing / 2.0
				grid_cell(1)%next_index = 2

				grid_cell(2)%x = dble(counter1) - grid_spacing / 2.0
				grid_cell(2)%y = dble(counter2) + grid_spacing / 2.0
				grid_cell(2)%next_index = 3

				grid_cell(3)%x = dble(counter1) + grid_spacing / 2.0
				grid_cell(3)%y = dble(counter2) + grid_spacing / 2.0
				grid_cell(3)%next_index = 4

				grid_cell(4)%x = dble(counter1) + grid_spacing / 2.0
				grid_cell(4)%y = dble(counter2) - grid_spacing / 2.0
				grid_cell(4)%next_index = 1



				call overlapping_polygon_sub(hexagon(hex_counter,:),hexagon_points, grid_cell, 4, overlap_polygon, overlap_size, &
                                                     overlap_point_count, warning)



				if (.not. warning) THEN

					if(overlap_point_count > 2) THEN
						area = polygon_area(overlap_polygon(1:overlap_point_count), overlap_point_count)

						area_ratio = area / (grid_spacing**2) / hexagon_area

						hexagon_thickness(hex_counter) = hexagon_thickness(hex_counter) + area_ratio * &
											   ice_grid(counter1,counter2)
					else
						area = 0.0
						area_ratio = 0.0
						
					endif
				else
					write(6,*) "Warning at hexagon centered at: ", hexagon_x(hex_counter), hexagon_y(hex_counter)
				endif

				call print_polygon(grid_cell, 4, area, 667)

				if(overlap_point_count > 0) THEN
					call print_polygon(overlap_polygon(1:overlap_point_count), overlap_point_count, area, 668)
				endif

			end do
		end do

		if(hexagon_thickness(hex_counter) > epsilon_factor) THEN ! DEFINITELY GET RID OF THIS IN THE FINAL VERSION
			if(hexagon_thickness(hex_counter) > biggest) THEN
				biggest = hexagon_thickness(hex_counter)
			endif

			if(hexagon_thickness(hex_counter) < smallest) THEN
				smallest = hexagon_thickness(hex_counter)
			endif
			call print_polygon(hexagon(hex_counter,:),hexagon_points, hexagon_thickness(hex_counter), out_unit)
		endif

	end do

	call hexagon_grid_clear()

	write(6,*) "thinnest: ", smallest
	write(6,*) "thickest: ", biggest

	close(out_unit)

end program fakegrid
