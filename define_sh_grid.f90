program define_sh_grid
	implicit none

! this program creates a spherical harmonic grid of spacing 360/N which is what ICE-5G was.

	integer :: degree, lat_index, long_index, boundary_index, counter, total_points, istat
	double precision :: grid_spacing, latitude, longitude, boundary_latitude, boundary_longitude


	character(len=80) :: dummy

	integer, parameter :: points_unit = 10, gmt_unit = 11
	integer, parameter :: boundary_spacing = 5
	character(len=80), parameter :: points_file = "lat_long_points.txt", gmt_file = "lat_long_poly.gmt"
	double precision, allocatable, dimension(:) :: latitude_array, longitude_array


	call get_command_argument(1,dummy)
	read(dummy,*) degree

	open(file=points_file, unit=points_unit, access="sequential", form="formatted", status="replace")
	open(file=gmt_file, unit=gmt_unit, access="sequential", form="formatted", status="replace")

	
	grid_spacing = 360. / dble(degree)

	allocate(latitude_array(boundary_spacing*4), longitude_array(boundary_spacing*4), stat=istat)
	if(istat /=0) THEN
		write(6,*) "allocate ISTAT: ", istat
	end if

	do lat_index = 1, degree / 2
		latitude = 90.-(dble(lat_index)-0.5)*grid_spacing
		do long_index = 1, degree

			longitude = (dble(long_index)-0.5)*grid_spacing

			write(points_unit,'(F9.5,1X,F9.5)') longitude, latitude


			total_points = 0
			do boundary_index = 1, boundary_spacing

				boundary_latitude = 90. - (dble(lat_index) - dble(boundary_index-1) / dble(boundary_spacing)) * grid_spacing
				boundary_longitude = dble(long_index-1) * grid_spacing
				total_points = total_points + 1
				latitude_array(total_points) = boundary_latitude
				longitude_array(total_points) = boundary_longitude



			end do

			do boundary_index = 1, boundary_spacing

				boundary_latitude = 90 - dble(lat_index-1) * grid_spacing
				boundary_longitude = (dble(long_index-1) + dble(boundary_index-1) / dble(boundary_spacing))  * grid_spacing 


				if (boundary_latitude < 90.0 .and. boundary_latitude > -90.0) THEN
					total_points = total_points + 1
					latitude_array(total_points) = boundary_latitude
					longitude_array(total_points) = boundary_longitude


				end if

			end do


			do boundary_index = 1, boundary_spacing

				boundary_latitude = 90. - (dble(lat_index-1) + dble(boundary_index-1) / dble(boundary_spacing)) * grid_spacing
				boundary_longitude = dble(long_index) * grid_spacing

				total_points = total_points + 1
				latitude_array(total_points) = boundary_latitude
				longitude_array(total_points) = boundary_longitude



			end do

			do boundary_index = 1, boundary_spacing

				boundary_latitude = 90.0 - dble(lat_index) * grid_spacing
				boundary_longitude = (dble(long_index) - dble(boundary_index-1) / dble(boundary_spacing))  * grid_spacing 

				if (boundary_latitude < 90.0 .and. boundary_latitude > -90.0) THEN
					total_points = total_points + 1
					latitude_array(total_points) = boundary_latitude
					longitude_array(total_points) = boundary_longitude


				end if

			end do

			! check no points are outside of what is possible

			do counter = 1, total_points

				if (latitude_array(counter) > 90.0) THEN
					latitude_array(counter) = 90.0
				end if

				if (latitude_array(counter) < -90.0) THEN
					latitude_array(counter) = 90.0
				end if

				if (longitude_array(counter) > 360.0) THEN
					longitude_array(counter) = 360.0
				end if

				if (longitude_array(counter) < 0.0) THEN
					longitude_array(counter) = 0.0
				end if

			end do

			! check if there are points 

			write(gmt_unit, '(A1,1X,I4)') ">", total_points
			do counter = 1, total_points
				write(gmt_unit,'(F9.5,1X,F9.5)') longitude_array(counter), latitude_array(counter)
			end do

		end do

	end do


	deallocate(latitude_array, longitude_array, stat=istat)
	if(istat /=0) THEN
		write(6,*) "deallocate ISTAT: ", istat
	end if
	close(unit=points_unit)
	close(unit=gmt_unit)


end program define_sh_grid
