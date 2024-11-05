program tegmarkgrid

	use hexagon_grid ! still need this for polygon_point
	use overlapping_polygon
	implicit none

	character(len=80), parameter :: info_file="file_info.txt",  out_file = "tegmark_hexagon_thickness.gmt"
	character(len=80), parameter :: polygon_file="hexagon_projected.gmt"
	character(len=80), parameter :: element_file = "element_thickness.txt"
	integer, parameter :: info_unit= 10, grid_unit=20,  hsize = 892, record_length = 4, out_unit = 60, overlap_size = 50
	integer, parameter :: poly_unit = 70, element_unit=80, max_points = 10 ! conservative
!	double precision, parameter :: hexagon_radius = 25000.0 ! 25 km radius
	double precision :: hexagon_radius	
	type(polygon_point), dimension(4) :: grid_cell
	type(polygon_point), dimension(overlap_size) ::overlap_polygon
	integer, dimension(:), allocatable :: point_count


	integer :: header_in_records, num_x, num_y, i, j, record_number, istat, num_points, polygon_counter
	double precision :: x_min_grid, x_max_grid, y_min_grid, y_max_grid, z_min_grid, z_max_grid, dx, dy
  	double precision :: x_min_local, x_max_local, y_min_local, y_max_local
	double precision :: hex_x_min, hex_x_max, hex_y_min, hex_y_max, area, area_ratio, hexagon_area
	integer :: counter1, counter2, hex_counter, overlap_point_count, resolution, n, counter

	logical :: warning
	integer :: x_counter_start, x_counter_end, y_counter_start, y_counter_end
	character(len=80) :: grid_file, dummy
	character(len=1) :: carrot
	real :: thickness
	double precision, dimension(:,:), allocatable :: ice_thickness


!	call get_command_argument(1,dummy)
!	read(dummy,*) hexagon_radius

	call get_command_argument(1,dummy)
	read(dummy,*) resolution


	n = 20*(2*resolution*(resolution-1)) + 12 ! number of points

	allocate(hexagon(n,max_points), point_count(n),hexagon_thickness(n))

	! read in the polygons
	polygon_counter = 0
	open(unit=poly_unit, file=polygon_file, access="sequential", form="formatted", status="old")

	read_poly: do

		read(poly_unit,*,iostat=istat) carrot, num_points
		if(istat /= 0) THEN
			exit read_poly
		endif
	
		polygon_counter = polygon_counter + 1
		point_count(polygon_counter) = num_points
		do counter = 1, num_points

			read(poly_unit, *) hexagon(polygon_counter,counter)%x, hexagon(polygon_counter,counter)%y 
			hexagon(polygon_counter,counter)%next_index = counter+1

		end do
		hexagon(polygon_counter,num_points)%next_index = 1

	end do read_poly

	close(unit=poly_unit)

	header_in_records = hsize / record_length

	open(unit=info_unit, file=info_file, access="sequential", form="formatted", status="old")

	read(info_unit,*) grid_file
	read(info_unit,*) x_min_grid
	read(info_unit,*) x_max_grid
	read(info_unit,*) y_min_grid
	read(info_unit,*) y_max_grid
	read(info_unit,*) z_min_grid
	read(info_unit,*) z_max_grid
	read(info_unit,*) dx
	read(info_unit,*) dy
	read(info_unit,*) num_x
	read(info_unit,*) num_y

	close(info_unit)


	allocate(ice_thickness(num_x, num_y))

	open(unit=grid_unit, file=grid_file, access="direct", form="unformatted", status="old", recl=record_length)

	do j = 1, num_y
		do i = 1, num_x

			record_number = (j-1) * num_x + (i-1)  + header_in_records

			read(grid_unit, rec=record_number, iostat=istat) thickness
			if(istat /= 0) THEN
				write(6,*) "problems reading in the file"
				write(6,*) "record_number = ", record_number
				write(6,*) "i, j", i, j
				stop
			endif

			ice_thickness(i,(num_y-j+1)) = dble(thickness)

		end do
	end do

	close(unit=grid_unit)


!	call definine_grid(x_min_grid, x_max_grid, y_min_grid, y_max_grid, hexagon_radius)

	open(unit=out_unit, file=out_file, access="sequential", form="formatted", status="replace")

	open(unit=element_unit, file=element_file, access="sequential", form="formatted", status="replace")

	hex_loop: do hex_counter = 1, n


		if(points_outside(hexagon(hex_counter,1:point_count(hex_counter)),point_count(hex_counter),&
                           x_min_grid, x_max_grid, y_min_grid, y_max_grid)) THEN
			cycle hex_loop
		endif

		call polygon_extremes(hexagon(hex_counter,1:point_count(hex_counter)),point_count(hex_counter),&
		  hex_x_min, hex_x_max, hex_y_min, hex_y_max)

		! assume that the grid is cell centered

		x_min_local = dble(floor(hex_x_min/dx)*dx)
		y_min_local = dble(floor(hex_y_min/dy)*dy)

		x_max_local = dble(ceiling(hex_x_max/dx)*dx)
		y_max_local = dble(ceiling(hex_y_max/dy)*dy)


		x_counter_start = nint((x_min_local-x_min_grid) / dx) 
		x_counter_end = nint((x_max_local-x_min_grid) / dx) + 1
		y_counter_start = nint((y_min_local-y_min_grid) / dy) 
		y_counter_end = nint((y_max_local-y_min_grid) / dy)  + 1

		! lazy hack for now
		if(x_counter_start < 1) THEN
			x_counter_start = 1
		endif

		if(y_counter_start < 1) THEN
			y_counter_start = 1
		endif
		
		if(x_counter_end > num_x) THEN
			x_counter_end = num_x
		endif
		if(y_counter_end > num_y) THEN
			y_counter_end = num_y
		endif

		if((x_counter_end < x_counter_start) .or. y_counter_end < y_counter_start) THEN
			hexagon_thickness(hex_counter) = 0.0
			cycle
		end if

		hexagon_area = polygon_area(hexagon(hex_counter,1:point_count(hex_counter)),point_count(hex_counter))

		do counter1 = x_counter_start, x_counter_end, 1
			do counter2 = y_counter_start, y_counter_end, 1

				if(ice_thickness(counter1,counter2) > 0) THEN

					! create grid cell polygon

					grid_cell(1)%x = dble(counter1-1)*dx - dx / 2.0 + x_min_grid
					grid_cell(1)%y = dble(counter2-1)*dy - dy / 2.0 + y_min_grid
					grid_cell(1)%next_index = 2

					grid_cell(2)%x = dble(counter1-1)*dx - dx / 2.0 + x_min_grid
					grid_cell(2)%y = dble(counter2-1)*dy + dy / 2.0 + y_min_grid
					grid_cell(2)%next_index = 3

					grid_cell(3)%x = dble(counter1-1) *dx+ dx / 2.0 + x_min_grid
					grid_cell(3)%y = dble(counter2-1)*dy + dy / 2.0 + y_min_grid
					grid_cell(3)%next_index = 4

					grid_cell(4)%x = dble(counter1-1)*dx + dx / 2.0 + x_min_grid
					grid_cell(4)%y = dble(counter2-1)*dy - dy / 2.0 + y_min_grid
					grid_cell(4)%next_index = 1



					call overlapping_polygon_sub(hexagon(hex_counter,1:point_count(hex_counter)),&
									     point_count(hex_counter), grid_cell, 4, overlap_polygon,  &
		                                               overlap_size,overlap_point_count, warning)



					if (.not. warning) THEN

						if(overlap_point_count > 2) THEN
							area = polygon_area(overlap_polygon(1:overlap_point_count), overlap_point_count)

							area_ratio = area  / hexagon_area


							hexagon_thickness(hex_counter) = hexagon_thickness(hex_counter) + area_ratio * &
												   ice_thickness(counter1,counter2)
						else
							area = 0.0
							area_ratio = 0.0
						
						endif
					else
						write(6,*) "Warning at hexagon centered at: ", hex_counter
					endif


				end if
			end do
		end do

		if(hexagon_thickness(hex_counter) > 1.0) THEN
			call print_polygon(hexagon(hex_counter,1:point_count(hex_counter)),point_count(hex_counter), &
				hexagon_thickness(hex_counter), out_unit)

			write(element_unit,*) hex_counter, hexagon_thickness(hex_counter)
		endif


	end do hex_loop
	close(unit=element_unit)
	close(unit=out_unit)

	deallocate(hexagon)
	deallocate(point_count)
	deallocate(ice_thickness)


end program tegmarkgrid

