program create_disc_file

	use hexagon_grid
	use overlapping_polygon
	implicit none

	character(len=100) :: file_name, dummy

	double precision :: hex_radius, x_min_grid, x_max_grid, y_min_grid, y_max_grid, z_min_grid, z_max_grid
	double precision :: x_increment, y_increment, increment, hexagon_radius, thickness
	double precision :: hex_x_min, hex_x_max, hex_y_min, hex_y_max
	integer :: x_size, y_size, istat, x_counter, y_counter, hex_counter

	double precision, allocatable, dimension(:,:) :: grid

	character(len=100), parameter :: grid_file = "grid.txt"
	integer, parameter :: grid_unit = 10

	call get_command_argument(1,file_name)

	call get_command_argument(2,dummy)
	read(dummy,*) x_min_grid
	call get_command_argument(3,dummy)
	read(dummy,*) x_max_grid
	call get_command_argument(4,dummy)
	read(dummy,*) y_min_grid
	call get_command_argument(5,dummy)
	read(dummy,*) y_max_grid
	call get_command_argument(6,dummy)
	read(dummy,*) z_min_grid
	call get_command_argument(7,dummy)
	read(dummy,*) z_max_grid
	call get_command_argument(8,dummy)
	read(dummy,*) x_increment
	call get_command_argument(9,dummy)
	read(dummy,*) y_increment
	call get_command_argument(10,dummy)
	read(dummy,*) x_size
	call get_command_argument(11,dummy)
	read(dummy,*) y_size
	call get_command_argument(12,dummy)
	read(dummy,*) hexagon_radius

	if(nint(x_increment) /= nint(y_increment)) THEN
		write(6,*) "error: x and y increments are not the same in ", file_name
		stop
	else
		increment = x_increment
	endif


	allocate(grid(x_size,y_size), stat=istat)
	if(istat /= 0) THEN
		write(6,*) "allocation failed"
		stop
	endif

	grid = 0.0

	open(unit=grid_unit, file=grid_file, access="sequential", form="formatted", status="old")

	read_file: do

		read(grid_unit,*,iostat=istat) x_counter, y_counter, thickness
		if(istat /= 0) THEN
			exit read_file
		endif

		if(thickness > 0) THEN ! avoid using negative thicknesses

			grid(x_counter,y_counter) = thickness
		endif

	end do read_file


	close(unit=grid_unit)
	

	! define grid
	write(6,*) x_min_grid, x_max_grid, y_min_grid, y_max_grid, hexagon_radius
	call definine_grid(x_min_grid, x_max_grid, y_min_grid, y_max_grid, hexagon_radius)


	do hex_counter = 1, number_hexagons
		call polygon_extremes(hexagon(hex_counter,hexagon_points),hexagon_points,hex_x_min, hex_x_max, hex_y_min, hex_y_max)

	end do

	deallocate(grid, stat=istat)
	if(istat /= 0) THEN
		write(6,*) "dellocation failed"
		stop
	endif

	call hexagon_grid_clear()
end program create_disc_file
