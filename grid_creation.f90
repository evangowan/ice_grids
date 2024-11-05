program grid_creation

	use hexagon_grid
	implicit none


	double precision :: x_min_in, x_max_in, y_min_in, y_max_in, grid_radius_in, last_x, last_y, distance
	integer :: counter, istat, counter2

	integer, parameter :: out_unit = 20, point_unit = 30
	character(len=80), parameter :: out_file = "hex_grid.gmt", point_file="points.txt"

	x_min_in = 0.0
	y_min_in = 0.0

	x_max_in = 100.0
	y_max_in = 100.0

	open(unit=20, file="limits.gmt", status="replace", form="formatted", access="sequential")

	write(20,'(A1)') ">"
	write(20,*) x_min_in, y_min_in
	write(20,*) x_min_in, y_max_in
	write(20,*) x_max_in, y_max_in
	write(20,*) x_max_in, y_min_in
	write(20,*) x_min_in, y_min_in

	grid_radius_in = 5.0
	close(unit=20)

	call definine_grid(x_min_in, x_max_in, y_min_in, y_max_in, grid_radius_in)

	open(unit=out_unit, file=out_file, status="replace", form="formatted", access="sequential")
	open(unit=point_unit, file=point_file, status="replace", form="formatted", access="sequential")

	do counter = 1, number_hexagons, 1

		write(point_unit,*) hexagon_x(counter), hexagon_y(counter)
		write(out_unit,'(A1)') ">"
		write(out_unit,*) hexagon(counter,hexagon_points)%x, hexagon(counter,hexagon_points)%y
!		last_x = hexagon_corner_x(counter,hexagon_points)
!		last_y = hexagon_corner_y(counter,hexagon_points)
		do counter2 = 1, hexagon_points
		
			write(out_unit,*) hexagon(counter,counter2)%x, hexagon(counter,counter2)%y

!			distance = sqrt( (hexagon_corner_x(counter,counter2) - last_x)**2 + (hexagon_corner_y(counter,counter2) - last_y)**2)
!			write(6,*) distance
!			last_x = hexagon_corner_x(counter,counter2)
!			last_y = hexagon_corner_y(counter,counter2)
		end do
	end do

	call hexagon_grid_clear()
	close(unit=out_unit)
	close(unit=point_unit)
end program
