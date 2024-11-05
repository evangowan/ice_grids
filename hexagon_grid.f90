module hexagon_grid

	implicit none
! this module contains the variables and subroutines that define the Tegmark grid

	! derived type describing the points of a polygon, used to simulate a linked list
	type polygon_point

		double precision :: x
		double precision :: y
		integer :: next_index

	end type polygon_point


	double precision, save :: x_min, x_max, y_min, y_max, grid_radius
	integer, save :: number_hexagons
	integer, parameter :: hexagon_points = 6

	double precision, allocatable, dimension(:) :: hexagon_x, hexagon_y, hexagon_thickness
	type(polygon_point), allocatable, dimension(:,:) :: hexagon

	
	double precision, parameter :: epsilon_factor = 1.0e-5
	double precision, parameter :: pi = 3.14159265359


contains

subroutine definine_grid(x_min_in, x_max_in, y_min_in, y_max_in, grid_radius_in)
	implicit none

	double precision, intent(in) :: x_min_in, x_max_in, y_min_in, y_max_in, grid_radius_in
	integer :: large_hexagon_row, hexagon_column, number_est_hexagons, counter

	integer :: shift_direction
	double precision :: x_temp, y_temp, angle, x_last, y_last
	type(polygon_point), dimension(6) :: temp_hex(hexagon_points)


	logical :: done, add_hex


	x_min = x_min_in
	x_max = x_max_in
	y_min = y_min_in
	y_max = y_max_in
	grid_radius = grid_radius_in

	! the grid is defined to start at the bottom left corner, centered on the hexagon, and designed to ensure that the entire input
	! regular grid is covered by hexagons

	large_hexagon_row = ceiling(((x_max - x_min)/grid_radius + 2.0)/2.0) ! plus one radii to account for the fact we are starting at the center of a hexagon

!	small_hexagon_row = large_hexagon_row - 2 ! should be true, I think

	hexagon_column = ceiling((y_max-y_min) / (2.0 * grid_radius) + 2.0)
	write(6,*) large_hexagon_row, hexagon_column

	number_est_hexagons = large_hexagon_row * hexagon_column * 2 ! should be a maximum estimate, but not too far off
	write(6,*) "number_est_hexagons: ", number_est_hexagons
	allocate(hexagon_x(number_est_hexagons), hexagon_y(number_est_hexagons), hexagon(number_est_hexagons, hexagon_points), &
        hexagon_thickness(number_est_hexagons))

	hexagon_thickness = 0

	number_hexagons = 1

	hexagon_x(number_hexagons) = x_min
	hexagon_y(number_hexagons) = y_min
	x_last = hexagon_x(number_hexagons)
	y_last = hexagon_y(number_hexagons)

	call hexagon_coordinates(hexagon_x(number_hexagons), hexagon_y(number_hexagons), grid_radius, &
        hexagon(number_hexagons,:))

	done = .false.

	shift_direction = 1.0

	do while (.not. done)

		if(shift_direction > 0) THEN
			x_temp = x_last + grid_radius * 2
			y_temp = y_last
			call hexagon_coordinates(x_temp, y_temp, grid_radius, temp_hex)

			if(temp_hex(3)%x > x_max .and. temp_hex(4)%x > x_max) THEN ! shift y up
				x_temp = x_temp + 2.0 * grid_radius * cos(pi / 3.0)
				y_temp = y_temp + 2.0 * grid_radius * sin(pi / 3.0)

				call hexagon_coordinates(x_temp, y_temp, grid_radius, temp_hex)
				shift_direction = -1.0
			endif



		else
			x_temp = x_last - grid_radius * 2
			y_temp = y_last
			call hexagon_coordinates(x_temp, y_temp, grid_radius, temp_hex)

			if(temp_hex(1)%x < x_min .and. temp_hex(6)%x < x_min) THEN ! shift y up
				x_temp = x_temp - 2.0 * grid_radius * cos(pi / 3.0)
				y_temp = y_temp + 2.0 * grid_radius * sin(pi / 3.0)

				call hexagon_coordinates(x_temp, y_temp, grid_radius, temp_hex)
				shift_direction = 1.0
			endif

		endif
!		write(6,*) x_temp, y_temp

		! check all corners to see if it is within range

		add_hex = .false.

		do counter = 1, hexagon_points, 1
			if (temp_hex(counter)%x > x_min .and. temp_hex(counter)%x < x_max) THEN
				add_hex = .true.
			endif
		end do

		! check if it goes above the y range

		if (temp_hex(3)%y >= y_max) THEN
			done = .true.
		endif
	

		if (add_hex .and. .not. done) THEN ! add the hexagon
			number_hexagons = number_hexagons + 1

			hexagon_x(number_hexagons) = x_temp
			hexagon_y(number_hexagons) = y_temp
			hexagon(number_hexagons,:) = temp_hex(:)

		endif

		x_last = x_temp
		y_last = y_temp

	end do
	write(6,*) "actual number of hexagons: ", number_hexagons

end subroutine definine_grid

subroutine hexagon_grid_clear()

	deallocate(hexagon_x, hexagon_y, hexagon, hexagon_thickness)

end subroutine hexagon_grid_clear

subroutine hexagon_coordinates(x, y, radius, corners)

	implicit none
	double precision, intent(in) :: x, y, radius
	type(polygon_point), dimension(hexagon_points), intent(out) :: corners

	double precision :: angle, dx, dy, distance

	! some corners are easy

	angle = pi / 6.0
	dx = radius
	dy = tan(angle) * radius

!	write(6,*) "length: ", 2.0 * radius * tan(angle)

	! clockwise for the Weiler–Atherton clipping algorithm

	corners(1)%x = x + dx
	corners(1)%y = y + dy
      corners(1)%next_index = 2

	corners(2)%x = x + dx
	corners(2)%y = y - dy
      corners(2)%next_index = 3

	! other two corners, I can just use the length from one of the previous corners

	distance = sqrt( (corners(1)%x - x)**2 + (corners(1)%y - y)**2)

	corners(3)%x = x
	corners(3)%y = y - distance
      corners(3)%next_index = 4


	corners(4)%x = x - dx
	corners(4)%y = y - dy
      corners(4)%next_index = 5



	corners(5)%x = x - dx
	corners(5)%y = y + dy
      corners(5)%next_index = 6

	corners(6)%x = x
	corners(6)%y = y + distance
      corners(6)%next_index = 1


	

end subroutine hexagon_coordinates

logical function same_point(point_a, point_b)
	implicit none
	type(polygon_point), intent(in) :: point_a, point_b

	if(abs(point_a%x-point_b%x) < epsilon_factor .and. abs(point_a%y-point_b%y) < epsilon_factor) THEN
		same_point = .true.
	else
		same_point = .false.
	endif

end function same_point

subroutine print_polygon(polygon, polygon_size, thickness, out_unit)
	implicit none
	integer, intent(in) :: polygon_size, out_unit
	type(polygon_point), intent(in), dimension(polygon_size) :: polygon
	double precision, intent(in) :: thickness
	integer :: counter
	character(len=80) :: temp_string

	write (temp_string, '(F20.8)') thickness

	temp_string =  ">-Z" //  adjustl(temp_string)
	write(out_unit,'(A80)') temp_string

	counter = 1
	going_around: do

		write(out_unit,*) polygon(counter)%x, polygon(counter)%y
		counter = polygon(counter)%next_index
		if(counter == 1) THEN
			exit going_around
		endif
	end do going_around

end subroutine print_polygon

subroutine polygon_extremes(polygon, polygon_size, poly_x_min, poly_x_max, poly_y_min, poly_y_max)
	implicit none
	integer, intent(in) :: polygon_size
	type(polygon_point), intent(in), dimension(polygon_size) :: polygon
	double precision, intent(out) :: poly_x_min, poly_x_max, poly_y_min, poly_y_max
	integer :: counter

	counter = 1

	! initialize
	poly_x_min = polygon(counter)%x
	poly_x_max = polygon(counter)%x
	poly_y_min = polygon(counter)%y
	poly_y_max = polygon(counter)%y

	going_around: do

		poly_x_min = min(polygon(counter)%x,poly_x_min)
		poly_x_max = max(polygon(counter)%x,poly_x_max)
		poly_y_min = min(polygon(counter)%y,poly_y_min)
		poly_y_max = max(polygon(counter)%y,poly_y_max)
		counter = polygon(counter)%next_index
		if(counter == 1) THEN
			exit going_around
		endif
	end do going_around


end subroutine polygon_extremes
	

logical function points_outside(polygon, polygon_size,  x_min_grid, x_max_grid, y_min_grid, y_max_grid)
! checks if any points in the polygon fall outside of the map range, if so it will return true
	implicit none
	integer, intent(in) :: polygon_size
	type(polygon_point), intent(in), dimension(polygon_size) :: polygon
	double precision, intent(in) ::  x_min_grid, x_max_grid, y_min_grid, y_max_grid
	integer :: counter

	points_outside = .false.

	counter = 1


	going_around: do

		if(polygon(counter)%x < x_min_grid .or. polygon(counter)%x > x_max_grid .or. &
		   polygon(counter)%y < y_min_grid .or. polygon(counter)%y > y_max_grid) THEN
			points_outside = .true.
			return
		endif


		counter = polygon(counter)%next_index
		if(counter == 1) THEN
			exit going_around
		endif
	end do going_around


end function points_outside

double precision function polygon_area(polygon, polygon_size)
	implicit none
	integer, intent(in) :: polygon_size
	type(polygon_point), intent(in), dimension(polygon_size) :: polygon

	integer :: counter, total_counter
	double precision :: total

	counter = 1
	total = 0.0
	total_counter = 1
	! Green's theorem for determining polygon area
	going_around: do

		total = total + (polygon(polygon(counter)%next_index)%x + polygon(counter)%x ) * &
				    (polygon(polygon(counter)%next_index)%y - polygon(counter)%y ) / 2.0

		counter = polygon(counter)%next_index
		if(counter == 1) THEN
			exit going_around
		endif

		total_counter = total_counter + 1

	end do going_around

	if(total_counter >= 3) THEN
		polygon_area = abs(total) ! since the polygon is oriented clockwise, the area will be negative in the above formula (http://mathworld.wolfram.com/PolygonArea.html)
	else
		polygon_area = 0
	endif
end function polygon_area

end module hexagon_grid
