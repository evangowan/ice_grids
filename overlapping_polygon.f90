module overlapping_polygon

	use hexagon_grid ! for type polygon_point
	implicit none


	type polygon_point_WA

		double precision :: x
		double precision :: y
		integer, dimension(3) :: next_index ! 1 is polygon1, 2 is polygon2, 3 is the overlapping polygon
		logical :: inside1, inside2, crossover

	end type polygon_point_WA

	integer, parameter :: p1 = 1, p2 = 2, p3 = 3 ! the next_index array



! want to find the percentage of overlap of between two polygons

! use Weiler–Atherton clipping algorithm




contains


! returns the overlapping polygon
subroutine overlapping_polygon_sub(polygon1, size1, polygon2, size2, overlap_polygon, size3, size3_out, warning)

	implicit none
	integer, intent(in) :: size1, size2, size3 ! the number of points in polygon1 and polygon2, and not different
	integer, intent(out) :: size3_out
	type(polygon_point), dimension(size1), intent(in) :: polygon1
	type(polygon_point), dimension(size2), intent(in) :: polygon2
	type(polygon_point), dimension(size3), intent(out) :: overlap_polygon
	logical, intent(out) :: warning ! if size3 is not large enough, then it will not return the polygon

	logical, dimension(size2) :: points_inside

	integer :: counter, size_WA, start_polygon1, start_polygon2, overlap_counter, current_point, current_point2, end_point
	integer :: counter2, current_point3, start_polygon3, next_point

	type(polygon_point_WA) :: temp_point_WA
	type(polygon_point_WA), dimension(:), allocatable :: overlapping
	logical :: is_crossover, all_inside1, all_outside1, all_inside2, all_outside2, overlap, identical,endpoint_found


	warning = .false.


	size_WA = 3*size1 + 3*size2 ! just a guess, but there will probably never be any more points than this

	allocate(overlapping(size_WA))

	! add all of the points to to the overlapping
	overlap_counter = 1
	start_polygon1 = 1
	current_point = 1

	all_inside1 = .true.
	all_outside1 = .true.

	do counter = 1, size1

		overlapping(overlap_counter)%x = polygon1(current_point)%x
		overlapping(overlap_counter)%y = polygon1(current_point)%y
		overlapping(overlap_counter)%next_index(p1) = overlap_counter + 1
		overlapping(overlap_counter)%next_index(p2) = 0 
		overlapping(overlap_counter)%next_index(p3) = 0
!		write(6,*) overlap_counter, current_point
!		write(6,*) overlapping(overlap_counter)%x, overlapping(overlap_counter)%y, polygon1(current_point)%x, polygon1(current_point)%y

		overlapping(overlap_counter)%inside1 = point_in_polygon(polygon2, size2, polygon1(current_point))
		if(.not. overlapping(overlap_counter)%inside1) THEN
			all_inside1 = .false.
		else
			all_outside1 = .false.
		endif
		overlapping(overlap_counter)%crossover = .false.
		overlap_counter = overlap_counter + 1

		current_point = polygon1(current_point)%next_index

	end do

	overlapping(overlap_counter-1)%next_index(p1) = start_polygon1
	start_polygon2 = overlap_counter

	current_point = start_polygon1
!	write(6,*) "checking"
!	check_loop: do

!		write(6,*) overlapping(current_point)%x, overlapping(current_point)%y, &
!		 overlapping(overlapping(current_point)%next_index(1))%x,&
!		 overlapping(overlapping(current_point)%next_index(1))%y

!		current_point = overlapping(current_point)%next_index(1)
!		if(current_point == start_polygon1) THEN
!			exit check_loop
!		endif

!	end do check_loop

	current_point = 1

	all_inside2 = .true.
	all_outside2 = .true.
	do counter = 1, size2

		overlapping(overlap_counter)%x = polygon2(current_point)%x
		overlapping(overlap_counter)%y = polygon2(current_point)%y
		overlapping(overlap_counter)%next_index(p1) = 0
		overlapping(overlap_counter)%next_index(p2) = overlap_counter + 1
		overlapping(overlap_counter)%next_index(p3) = 0


!		write(6,*) overlap_counter, current_point
!		write(6,*) overlapping(overlap_counter)%x, overlapping(overlap_counter)%y, polygon2(current_point)%x, polygon2(current_point)%y


		overlapping(overlap_counter)%crossover = .false.

		overlapping(overlap_counter)%inside2 = point_in_polygon(polygon1, size1, polygon2(current_point))
		if(.not. overlapping(overlap_counter)%inside2) THEN
			all_inside2 = .false.
		else
			all_outside2 = .false.
		endif

		overlap_counter = overlap_counter + 1
		current_point = polygon2(current_point)%next_index


	end do

	overlapping(overlap_counter-1)%next_index(p2) = start_polygon2


!	current_point = start_polygon2
!	write(6,*) "checking2"
!	check_loop2: do

!		write(6,*) overlapping(current_point)%x, overlapping(current_point)%y, &
!		 overlapping(overlapping(current_point)%next_index(2))%x,&
!		 overlapping(overlapping(current_point)%next_index(2))%y

!		current_point = overlapping(current_point)%next_index(2)
!		if(current_point == start_polygon2) THEN
!			exit check_loop2
!		endif

!	end do check_loop2

	! check if there are points in the second polygon that are identical to the first polygon

	current_point2 = start_polygon2

	same_check: do 
		current_point = start_polygon1
		loop_first: do


			if(same_point_wa(overlapping(current_point), overlapping(current_point2))) THEN ! change the pointers

				! find the point that is pointing at current_point2 and change it

				current_point3 = start_polygon2
				loop_third: do
					if(overlapping(current_point3)%next_index(2) == current_point2) THEN
						overlapping(current_point3)%next_index(2) = current_point
						exit loop_third
					endif

					current_point3 = overlapping(current_point3)%next_index(2)


				end do loop_third

				! change the pointer of polygon1 point that is the same
				overlapping(current_point)%next_index(2) = overlapping(current_point2)%next_index(2)

				if(current_point2 == start_polygon2) THEN ! change the starting point
					start_polygon2 = current_point
				endif
				current_point2 = current_point

				! set the status of the point to indicate there is a crossover
				overlapping(current_point)%crossover = .true.
				exit loop_first
			endif

			! increment
			current_point = overlapping(current_point)%next_index(1)
			if(current_point == start_polygon1) THEN
				exit loop_first
			endif

		end do loop_first
		current_point2 = overlapping(current_point2)%next_index(2)
		if(current_point2 == start_polygon2) THEN
			exit same_check
		endif

	end do same_check


	! check if any points on polygon 2 fall directly on polygon 1
	current_point = start_polygon1

	check_polygon1: do



		next_point = overlapping(current_point)%next_index(1)
		current_point2 = start_polygon2
		check_other_polygon1: do



			if (point_on_line(overlapping(current_point), overlapping(next_point), overlapping(current_point2)) .and. &
			    .not. overlapping(current_point2)%crossover ) THEN ! put this point onto the first polygon


				
				overlapping(current_point)%next_index(1) = current_point2
				overlapping(current_point2)%next_index(1) = next_point
				overlapping(current_point2)%crossover = .true.


				cycle check_polygon1
				
			endif
			current_point2 = overlapping(current_point2)%next_index(2)
			if(current_point2 == start_polygon2) THEN
				exit check_other_polygon1
			endif

		end do check_other_polygon1

		current_point = next_point
		if(current_point == start_polygon1) THEN
			exit check_polygon1
		endif


	end do check_polygon1



	! check if any points on polygon 1 fall directly on polygon 2
	current_point2 = start_polygon2

	check_polygon2: do


		next_point = overlapping(current_point2)%next_index(2)
		current_point = start_polygon1
		check_other_polygon2: do



			if (point_on_line(overlapping(current_point2), overlapping(next_point), overlapping(current_point)) .and. &
			    .not. overlapping(current_point)%crossover ) THEN ! put this point onto the second polygon
				
				overlapping(current_point2)%next_index(2) = current_point
				overlapping(current_point)%next_index(2) = next_point
				overlapping(current_point)%crossover = .true.
				cycle check_polygon2
				
			endif
			current_point = overlapping(current_point)%next_index(1)
			if(current_point == start_polygon1) THEN
				exit check_other_polygon2
			endif

		end do check_other_polygon2

		current_point2 = next_point
		if(current_point2 == start_polygon2) THEN
			exit check_polygon2
		endif

	end do check_polygon2

	! find the intersecting points

	current_point = start_polygon1

	find_intersecting: do

		current_point2 = start_polygon2
		loop_second: do


			if(current_point == current_point2 .or. current_point == overlapping(current_point2)%next_index(p2) .or. &
			   overlapping(current_point)%next_index(p1) == current_point2 .or. &
			   overlapping(current_point)%next_index(p1) == overlapping(current_point2)%next_index(p2) ) THEN ! no need to check
				is_crossover = .false.
			else
				call crossover_point(overlapping(current_point), overlapping(overlapping(current_point)%next_index(p1)), &
					    overlapping(current_point2), overlapping(overlapping(current_point2)%next_index(p2)), &
					    temp_point_WA, is_crossover, overlap)


			endif


			if(is_crossover) THEN ! add the point

				if(same_point_WA(temp_point_WA,overlapping(current_point)) ) THEN ! point passes through the second polygon
!					write(6,*) "point passes through the second polygon 1"
					overlapping(current_point)%next_index(p2) = overlapping(current_point2)%next_index(p2)
					overlapping(current_point2)%next_index(p2) = current_point
					overlapping(current_point)%crossover = .true.
				elseif(same_point_WA(temp_point_WA,overlapping(overlapping(current_point)%next_index(p1))) ) THEN ! point passes through the second polygon
!					write(6,*) "point passes through the second polygon 2"
					overlapping(overlapping(current_point)%next_index(p1))%next_index(p2) = overlapping(current_point2)%next_index(p2)
					overlapping(current_point2)%next_index(p2) = overlapping(current_point)%next_index(p1)
					overlapping(overlapping(current_point)%next_index(p1))%crossover = .true.
				elseif(same_point_WA(temp_point_WA,overlapping(current_point2)) ) THEN ! point passes through the first polygon
!					write(6,*) " point passes through the first polygon 1"
					overlapping(current_point2)%next_index(p1) = overlapping(current_point)%next_index(p1)
					overlapping(current_point)%next_index(p1) = current_point2
					overlapping(current_point2)%crossover = .true.
				elseif(same_point_WA(temp_point_WA,overlapping(overlapping(current_point2)%next_index(p2))) ) THEN ! point passes through the first polygon
!					write(6,*) " point passes through the first polygon 2"
					overlapping(overlapping(current_point2)%next_index(p2))%next_index(p1) = overlapping(current_point)%next_index(p1)
					overlapping(current_point)%next_index(p1) = overlapping(current_point2)%next_index(p2)
					overlapping(overlapping(current_point2)%next_index(p2))%crossover = .true.
				else
!					write(6,*) "other"
					overlapping(overlap_counter) = temp_point_WA
					overlapping(overlap_counter)%next_index(p1) = overlapping(current_point)%next_index(p1)
					overlapping(overlap_counter)%next_index(p2) = overlapping(current_point2)%next_index(p2)
					overlapping(overlap_counter)%next_index(p3) = 0
					overlapping(overlap_counter)%inside1 = .false.
					overlapping(overlap_counter)%inside2 = .false.
					overlapping(overlap_counter)%crossover = .true.
					overlapping(current_point)%next_index(p1) = overlap_counter
					overlapping(current_point2)%next_index(p2) = overlap_counter
					overlap_counter = overlap_counter + 1
				endif
				all_inside1 = .false.
				all_outside1 = .false.
				all_inside2 = .false.
				all_outside2 = .false.
				cycle find_intersecting
			else
				current_point2 = overlapping(current_point2)%next_index(p2) 
				if(current_point2 == start_polygon2) THEN
					exit loop_second
				endif

			endif


		end do loop_second

		current_point = overlapping(current_point)%next_index(p1)

		if(current_point == start_polygon1) THEN
			exit find_intersecting
		end if

	end do find_intersecting
	overlap_counter = overlap_counter - 1

!	write(6,*) "found all intersectiong points"
!	call print_polygon_wa(overlapping(1:overlap_counter),overlap_counter,6)

	size3_out = 0
	if (all_inside2) THEN ! the polygon should be the same as the clipping polygon
		overlap_polygon(1:size2) = polygon2
		size3_out = size2
	elseif (all_inside1) THEN ! the polygon should be the same as the input polygon
		overlap_polygon(1:size1) = polygon1
		size3_out = size1
	else if (all_outside1 .and. all_outside2) THEN ! there is no overlap
		size3_out = 0
	else ! circle around
		current_point = start_polygon1
		search_for_first: do
!			write(6,*) current_point, overlapping(current_point)%next_index(1),overlapping(current_point)%crossover, &
!				all_inside1, all_inside2, all_outside1, all_outside2
			if(overlapping(current_point)%crossover) THEN ! found first point
				end_point = current_point
				exit search_for_first
			end if
			current_point = overlapping(current_point)%next_index(1)

			if(current_point == 1) THEN

				call print_polygon(polygon1,size1,0.d0,6)
				call print_polygon(polygon2,size2,0.d0,6)
				call print_polygon_wa(overlapping(1:overlap_counter),overlap_counter,6)
				write(6,*) "dkjfa;lkfj;adsfklj"
				stop	
			endif

		end do search_for_first

		! now that the first point has been found, loop around
!			write(6,*) "found first"
		create_overlap: do
!				write(6,*) "end_point: ", end_point
!				call print_polygon_wa(overlapping(1:overlap_counter),overlap_counter,6)
			if(overlapping(current_point)%crossover) THEN ! decide if it uses p1 or p2



				if(overlapping(overlapping(current_point)%next_index(p2))%inside2 .or. &
			         overlapping(overlapping(current_point)%next_index(p2))%crossover) THEN ! the next point is is on the second polygon
					if(   overlapping(overlapping(current_point)%next_index(p2))%next_index(p3) == 0) THEN
						overlapping(current_point)%next_index(p3) = overlapping(current_point)%next_index(p2)
						current_point = overlapping(current_point)%next_index(p2)
					else
						overlapping(current_point)%next_index(p3) = end_point !current_point
						current_point = end_point
					endif
!					write(6,*) "going along second polygon"
				else if (overlapping(overlapping(current_point)%next_index(p1))%inside1 .or. &
			                overlapping(overlapping(current_point)%next_index(p1))%crossover) THEN

					if(   overlapping(overlapping(current_point)%next_index(p1))%next_index(p3) == 0) THEN
						overlapping(current_point)%next_index(p3) = overlapping(current_point)%next_index(p1)
						current_point = overlapping(current_point)%next_index(p1)
					else
						overlapping(current_point)%next_index(p3) = end_point !current_point
						current_point = end_point
					endif

				else
					overlapping(current_point)%next_index(p3) = end_point !current_point
					current_point = end_point
!					write(6,*) "Single point"

				endif
			else 
 
				if (overlapping(current_point)%next_index(p1) /= 0) THEN ! go along the first polygon
					overlapping(current_point)%next_index(p3) = overlapping(current_point)%next_index(p1)
					current_point = overlapping(current_point)%next_index(p1)
				else if  (overlapping(current_point)%next_index(p2) /= 0) THEN ! go along the second polygon
					overlapping(current_point)%next_index(p3) = overlapping(current_point)%next_index(p2)
					current_point = overlapping(current_point)%next_index(p2)
				else
					write(6,*) "there is a bug in the program"
					stop
				endif
			endif 

			if (current_point == end_point) THEN ! found the overlapping polygon
				exit create_overlap
			endif

		end do create_overlap


		if(current_point == 0) THEN
			write(6,*) "there is something wrong", current_point, end_point
			stop
		endif

		! fill up the overlapping polygon
		counter = 1
		fill_overlap: do
!			write(6,*) counter,overlapping(current_point)%next_index(p3), end_point
			overlap_polygon(counter)%x = overlapping(current_point)%x
			overlap_polygon(counter)%y = overlapping(current_point)%y
!			write(6,*) counter,current_point,overlap_polygon(counter)%x, overlap_polygon(counter)%y, &
!				overlapping(current_point)%next_index(p3), end_point
			if(overlapping(current_point)%next_index(p3) /= end_point) THEN

				overlap_polygon(counter)%next_index = counter+1
				counter = counter + 1

				if (counter > size3) THEN ! there will be a segmentation fault
					counter = size3
					write(6,*) "counter too large: ", counter, size3
					warning = .true.
					exit fill_overlap
				end if



			else
				overlap_polygon(counter)%next_index = 1
				exit fill_overlap
			endif
			current_point = overlapping(current_point)%next_index(p3)
		end do fill_overlap

		size3_out = counter

	end if 

!	call print_polygon_wa(overlapping(1:overlap_counter),overlap_counter,6)
!	write(6,*) ">>>>>"
!	do counter = 1, overlap_counter-1

!		write(6,*) overlapping(counter)%x, overlapping(counter)%y, overlapping(counter)%crossover
!
!	end do
!	write(6,*) ">>>>>"

	
	deallocate(overlapping)

end subroutine overlapping_polygon_sub


! new version that uses type polygon_point, much more efficient code with the psudo-pointers
logical function point_in_polygon(polygon, number_points, point)

! this function determines whether a give point is within a polygon
	
	implicit none

	integer, intent(in) :: number_points
	type(polygon_point), intent(in) :: point
	type(polygon_point), dimension(number_points), intent(in) :: polygon

	integer :: current_point, next_point, counter
	logical :: inside

	inside = .false.

	current_point = 1

	search_boundary: do counter = 1, number_points

		next_point = polygon(current_point)%next_index
	
		! even-odd rule algorithm to determine if the point is inside or outside

		if (min(polygon(current_point)%y, polygon(next_point)%y) < point%y .and.&
		    max(polygon(current_point)%y, polygon(next_point)%y) >= point%y) THEN

			if (polygon(current_point)%x + (point%y - polygon(current_point)%y) /&
			    (polygon(next_point)%y - polygon(current_point)%y) * &
			    (polygon(next_point)%x - polygon(current_point)%x) < point%x) THEN

				inside = .not.(inside)

			endif

		endif

		current_point = next_point

	end do search_boundary

	point_in_polygon = inside

	return
end function point_in_polygon


logical function point_on_line(point_a1, point_a2, point_b1)

	! returns true if point_b1 lies between point_a1 and point_a2
	implicit none


	type(polygon_point_WA), intent(in) :: point_a1, point_a2, point_b1
	double precision :: slope1, intercept1
	type(polygon_point_WA) :: temp

	slope1 = (point_a2%y - point_a1%y) / (point_a2%x - point_a1%x) 
	intercept1 = point_a2%y - point_a2%x * slope1


	if(abs(point_a2%x - point_a1%x) < epsilon_factor) then ! line is parallel to the y-axis
		temp%x = point_a1%x
		if(point_b1%y > min(point_a2%y, point_a1%y) .and. point_b1%y < max(point_a2%y, point_a1%y)) THEN
			temp%y = point_b1%y
		else
			temp%y = point_a2%y ! dummy
		endif

	elseif(abs(point_a2%y - point_a1%y) < epsilon_factor) then ! line is parallel to the x-axis

		temp%y = point_a1%y

		if(point_b1%x > min(point_a2%x, point_a1%x) .and. point_b1%x < max(point_a2%x, point_a1%x)) THEN
			temp%x = point_b1%x
		else
			temp%x = point_a2%x ! dummy
		endif
	else
		temp%x = point_b1%x
		temp%y = slope1 * temp%x * intercept1
	endif

	if (same_point_wa(point_b1, temp) .and. .not. same_point_wa(point_a1, temp).and. .not. same_point_wa(point_a2, temp)) THEN
		point_on_line=.true.
	else
		point_on_line = .false.
	endif


	

end function point_on_line

! changed this to use type polygon_point

subroutine crossover_point(point_a1, point_a2, point_b1, point_b2, crossover, is_crossover, overlap)

	! checks if the two given line segments overlap. If they do, this subroutine returns the crossover point

	implicit none

	type(polygon_point_WA), intent(in) :: point_a1, point_a2, point_b1, point_b2

	type(polygon_point_WA), intent(out) :: crossover
	logical, intent(out) :: is_crossover, overlap

	double precision :: slope1, slope2, intercept1, intercept2, a_min_cell_x, a_min_cell_y, a_max_cell_x, a_max_cell_y
	double precision :: b_min_cell_x, b_min_cell_y, b_max_cell_x, b_max_cell_y
	double precision :: temp_x, temp_y




	a_min_cell_x = min(point_a1%x, point_a2%x)
	a_min_cell_y = min(point_a1%y, point_a2%y)
	a_max_cell_x = max(point_a1%x, point_a2%x)
	a_max_cell_y = max(point_a1%y, point_a2%y)

	b_min_cell_x = min(point_b1%x, point_b2%x)
	b_min_cell_y = min(point_b1%y, point_b2%y)
	b_max_cell_x = max(point_b1%x, point_b2%x)
	b_max_cell_y = max(point_b1%y, point_b2%y)


	is_crossover = .false.
	overlap = .false.


	if(same_point_wa(point_a1,point_b1) .or. same_point_wa(point_a1,point_b2) .or. &
	   same_point_wa(point_a2,point_b1) .or. same_point_wa(point_a2,point_b2)) THEN
		overlap = .true.
		return
	endif


	slope1 = (point_a2%y - point_a1%y) / (point_a2%x - point_a1%x) 
	intercept1 = point_a2%y - point_a2%x * slope1

	slope2 = (point_b2%y - point_b1%y) / (point_b2%x - point_b1%x) 
	intercept2 = point_b2%y - point_b2%x  * slope2

	if (abs(point_a2%x - point_a1%x) < epsilon_factor .and. abs(point_b2%x - point_b1%x) < epsilon_factor) then ! both lines are parallel to y
		if (abs(point_b1%x - point_a1%x) < epsilon_factor .and. a_min_cell_y < b_max_cell_y) THEN ! there is overlap

			overlap = .true.
			return
		else
			return

		endif

	elseif(abs(point_a2%x - point_a1%x) < epsilon_factor) then ! first line is parallel to the y-axis
		temp_x = point_a2%x
		temp_y = slope2 * temp_x + intercept2
	elseif(abs(point_b2%x - point_b1%x) < epsilon_factor) THEN ! second line is parallel to the y-axis
		temp_x = point_b2%x
		temp_y = slope1 * temp_x + intercept1


	elseif(abs(slope1-slope2) < epsilon_factor) THEN ! the slopes are essentially identical
		temp_y = slope1 * point_b1%x + intercept1

		if((point_b1%y-temp_y) < epsilon_factor) THEN ! overlap exists
			overlap = .true.
			return
		endif

		temp_y = slope1 * point_b2%x + intercept1
		if((point_b2%y-temp_y) < epsilon_factor) THEN ! overlap exists
			overlap = .true.

		endif

		return

	elseif(abs(point_a2%y - point_a1%y) < epsilon_factor) then  ! first line is parallel to the x-axis
		temp_x = (intercept2 - intercept1) / (slope1 - slope2)
		temp_y = point_a2%y

	elseif(abs(point_b2%y - point_b1%y) < epsilon_factor) then  ! second line is parallel to the x-axis
		temp_x = (intercept2 - intercept1) / (slope1 - slope2)
		temp_y = point_b2%y

	else 

		temp_x = (intercept2 - intercept1) / (slope1 - slope2)
		temp_y = slope1 * temp_x + intercept1

	endif


	crossover%x = temp_x
	crossover%y = temp_y
	is_crossover = .false.
	if(temp_x >= a_min_cell_x) THEN
	  if(temp_x <= a_max_cell_x) THEN
	     if(temp_x >= b_min_cell_x) THEN
		 if(temp_x <= b_max_cell_x) THEN
	   	   if(temp_y >= a_min_cell_y) THEN
		     if(temp_y <= a_max_cell_y) THEN
	   		 if(temp_y >= b_min_cell_y) THEN
			   if(temp_y <= b_max_cell_y) THEN

				is_crossover = .true.

			   endif
			 endif
		     endif
		   endif
		 endif
	     endif
	   endif
	endif



end subroutine crossover_point

logical function same_point_wa(point_a, point_b)
	implicit none
	type(polygon_point_WA), intent(in) :: point_a, point_b

	if(abs(point_a%x-point_b%x) < epsilon_factor .and. abs(point_a%y-point_b%y) < epsilon_factor) THEN
		same_point_wa = .true.
	else
		same_point_wa = .false.
	endif

end function same_point_wa



subroutine print_polygon_wa(polygon, polygon_size, out_unit)
	implicit none
	integer, intent(in) :: polygon_size, out_unit
	type(polygon_point_wa), intent(in), dimension(polygon_size) :: polygon
	integer :: counter
	character(len=80) :: temp_string


	temp_string =  "> overlap"
	write(out_unit,'(A80)') temp_string

	
	going_around: do counter = 1, polygon_size

		write(out_unit,*) polygon(counter)%x, polygon(counter)%y, polygon(counter)%next_index(1), &
			 polygon(counter)%next_index(2), polygon(counter)%next_index(3), polygon(counter)%crossover


	end do going_around

end subroutine print_polygon_wa


end module overlapping_polygon
