

program sh_grid

	use hexagon_grid ! still need this for polygon_point
	use overlapping_polygon
	implicit none

	type ice_element
		double precision :: latitude, longitude, ice_thickness, area
	end type ice_element

	! it is necessary to project the grid before running this program. It is also expected that the points in
	! the point file corresponds to what is in the grid file

    ! the current maximum number of points in the polygons in the grid file is 100

	character(len=80), parameter :: input_point_file="lat_long_points.txt", out_file = "sh_polygon_thickness.gmt"
	character(len=80), parameter :: polygon_file="sh_projected.gmt", info_file = "file_info.txt"
	character(len=80), parameter :: element_file = "sh_element_thickness.txt"
	integer, parameter :: input_unit= 10, info_unit=20, grid_unit=30, out_unit = 60, overlap_size = 50
	! GMT binary file header format parameters
	integer, parameter :: hsize = 892, record_length = 4
	integer, parameter :: poly_unit = 70, element_unit=80, max_points = 100 ! conservative

	type(polygon_point), dimension(max_points) :: current_polygon

	type(polygon_point), dimension(4) :: grid_cell
	type(polygon_point), dimension(overlap_size) ::overlap_polygon
	integer :: point_count

	double precision, allocatable, dimension(:,:) :: ice_thickness

	integer :: header_in_records, num_x, num_y, i, j, record_number, istat, num_points, polygon_counter
	double precision :: x_min_grid, x_max_grid, y_min_grid, y_max_grid, z_min_grid, z_max_grid, dx, dy
  	double precision :: x_min_local, x_max_local, y_min_local, y_max_local
	double precision :: x_min_poly, x_max_poly, y_min_poly, y_max_poly, area, area_ratio, hexagon_area
	integer :: counter1, counter2, hex_counter, overlap_point_count, resolution, n, counter

	logical :: warning
	integer :: x_counter_start, x_counter_end, y_counter_start, y_counter_end
	character(len=80) :: grid_file, dummy
	character(len=1) :: carrot
	real :: thickness

	type(ice_element), allocatable, dimension(:) :: elements

	write(6,*) "reading the spherical harmonic compatible grid"
	open(file=input_point_file, unit=input_unit, access="sequential", form="formatted", status="old")
	num_points = 0
	read_input1: do
		read (input_unit,*, iostat=istat) dummy
		if(istat /= 0) THEN
			exit read_input1
		end if
		num_points = num_points + 1
	end do read_input1

	rewind(unit=input_unit)

	allocate(elements(num_points))

	read_input2: do counter1 = 1, num_points
		read (input_unit,*, iostat=istat) elements(counter1)%longitude, elements(counter1)%latitude

		elements(counter1)%ice_thickness = 0.0
		elements(counter1)%area = 0.0
	end do read_input2

	close(unit=input_unit)

	! read in the polygons
	write(6,*) "reading polygons to find the area"
	polygon_counter = 0
	open(unit=poly_unit, file=polygon_file, access="sequential", form="formatted", status="old")


	read_polygons1: do counter = 1, num_points

		read(poly_unit, *) dummy, point_count

		do polygon_counter = 1, point_count
			read(poly_unit, *) current_polygon(polygon_counter)%x, current_polygon(polygon_counter)%y
			current_polygon(polygon_counter)%next_index = polygon_counter + 1
		end do

		current_polygon(point_count)%next_index = 1
		elements(counter)%area = polygon_area(current_polygon(1:point_count), point_count)

	end do read_polygons1

	rewind(unit=poly_unit)

	write(6,*) "reading the header information for the ice grid"
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

	header_in_records = hsize / record_length

	write(6,*) "reading ice thickness from ICSHEET output"
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



	open(unit=out_unit, file=out_file, access="sequential", form="formatted", status="replace")

	open(unit=element_unit, file=element_file, access="sequential", form="formatted", status="replace")

	write(6,*) "looping through all the element polygons to see if there is ice in them"

	grid_loop: do counter = 1, num_points

		read(poly_unit, *) dummy, point_count

		do polygon_counter = 1, point_count
			read(poly_unit, *) current_polygon(polygon_counter)%x, current_polygon(polygon_counter)%y
			current_polygon(polygon_counter)%next_index = polygon_counter + 1
		end do

		current_polygon(point_count)%next_index = 1

		if(points_outside(current_polygon(1:point_count),point_count,&
                           x_min_grid, x_max_grid, y_min_grid, y_max_grid)) THEN
			write(element_unit,'(F7.1)') elements(counter)%ice_thickness
			cycle grid_loop
		endif

		call polygon_extremes(current_polygon(1:point_count),point_count,&
		  x_min_poly, x_max_poly, y_min_poly, y_max_poly)

		! assume that the grid is cell centered

		x_min_local = dble(floor(x_min_poly/dx)*dx)
		y_min_local = dble(floor(y_min_poly/dy)*dy)

		x_max_local = dble(ceiling(x_max_poly/dx)*dx)
		y_max_local = dble(ceiling(y_max_poly/dy)*dy)


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
			cycle
		end if

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



					call overlapping_polygon_sub(current_polygon(1:point_count),&
									     point_count, grid_cell, 4, overlap_polygon,  &
		                                               overlap_size,overlap_point_count, warning)



					if (.not. warning) THEN

						if(overlap_point_count > 2) THEN


							area = polygon_area(overlap_polygon(1:overlap_point_count), overlap_point_count)

							area_ratio = area  / elements(counter)%area

						
							if (elements(counter)%area < 0.01) THEN
								write(6,*) "incorrect error at ", counter
								stop
							endif

							elements(counter)%ice_thickness = elements(counter)%ice_thickness + area_ratio * &
												   ice_thickness(counter1,counter2)
						else
							area = 0.0
							area_ratio = 0.0
						
						endif
					else
						write(6,*) "Warning at polygon centered at: ", counter
					endif


				end if
			end do
		end do

		if(elements(counter)%ice_thickness > 1.0) THEN
			call print_polygon(current_polygon(1:point_count),point_count, &
				elements(counter)%ice_thickness, out_unit)


		endif

		write(element_unit,'(F7.1)') elements(counter)%ice_thickness


	end do grid_loop
	close(unit=poly_unit)
	close(unit=element_unit)
	close(unit=out_unit)

	deallocate(elements)
	deallocate(ice_thickness)


end program sh_grid

