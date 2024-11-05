program test_overlap

	use hexagon_grid
	use overlapping_polygon

	implicit none

	type(polygon_point), dimension(4) :: square1, square2, temp_square
	type(polygon_point), dimension(8) ::  overlap

	integer :: counter, size3_out
	double precision, dimension(4) :: corner_x, corner_y
	logical :: warning

	corner_x(1) = 0.
	corner_x(2) = 1.
	corner_x(3) = 1.
	corner_x(4) = 0.
	
	corner_y(1) = 0.
	corner_y(2) = 0.
	corner_y(3) = 1.
	corner_y(4) = 1. 


!	corner_x(1) = -0.4
!	corner_x(2) = 0.5
!	corner_x(3) = 1.4
!	corner_x(4) = 0.5
	
!	corner_y(1) = 0.5
!	corner_y(2) = -0.4
!	corner_y(3) = 0.5
!	corner_y(4) = 1.4 

	do counter = 1, 4
		square1(counter)%x = corner_x(counter)
		square1(counter)%y = corner_y(counter)

		square2(counter)%x = corner_x(counter) + 0.5
		square2(counter)%y = corner_y(counter) + 0.5

		if(counter < 4) THEN
			square1(counter)%next_index = counter + 1
			square2(counter)%next_index = counter + 1
		else
			square1(counter)%next_index = 1
			square2(counter)%next_index = 1
		endif

	end do
	


!	corner_x(1) = -1.
!	corner_x(2) = 2.
!	corner_x(3) = 2.
!	corner_x(4) = -1.
	
!	corner_y(1) = -1.
!	corner_y(2) = -1.
!	corner_y(3) = 2.
!	corner_y(4) = 2. 

!	do counter = 1, 4


!		square2(counter)%x = corner_x(counter)
!		square2(counter)%y = corner_y(counter)

!		if(counter < 4) THEN

!			square2(counter)%next_index = counter + 1
!		else

!			square2(counter)%next_index = 1
!		endif

!	end do

!	square2(1)%x = square1(1)%x
!	square2(1)%y = square1(1)%y

!	square2(2)%x = square1(2)%x
!	square2(2)%y = square1(2)%y

	corner_x(1) = -0.4
	corner_x(2) = 0.5
	corner_x(3) = 1.4
	corner_x(4) = 0.5
	
	corner_y(1) = 0.5
	corner_y(2) = -0.4
	corner_y(3) = 0.5
	corner_y(4) = 1.4 

!	do counter = 1, 4


!		square2(counter)%x = corner_x(counter) + .1
!		square2(counter)%y = corner_y(counter) + .1

!		if(counter < 4) THEN

!			square2(counter)%next_index = counter + 1
!		else

!			square2(counter)%next_index = 1
!		endif

!	end do


!	temp_square = square1
!	square1 = square2
!	square2 = temp_square	

	call overlapping_polygon_sub(square1, 4, square2, 4, overlap, 8, size3_out, warning)

	if(warning) THEN
		write(6,*) "the assigned memory for the overlap polygon is not enough"
	else

		write(6,*) ">"
		do counter = 1, 4

			write(6,*) square1(counter)%x, square1(counter)%y


		end do	
		write(6,*) square1(1)%x, square1(1)%y

		write(6,*) ">"
		do counter = 1, 4

			write(6,*) square2(counter)%x, square2(counter)%y


		end do
		write(6,*) square2(1)%x, square2(1)%y


		if(size3_out > 0) THEN
			write(6,*) ">"
			do counter = 1, size3_out

				write(6,*) overlap(counter)%x, overlap(counter)%y


			end do	
			write(6,*) overlap(1)%x, overlap(1)%y
		else
			write(6,*) "no overlap"
		endif


	end if

	write(6,*) "area_1: ", polygon_area(square1, 4)
	write(6,*) "area_2: ", polygon_area(square2, 4)
	write(6,*) "area_o: ", polygon_area(overlap, size3_out)

end program test_overlap
