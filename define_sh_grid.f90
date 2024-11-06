program define_sh_grid
	implicit none

! this program creates a spherical harmonic grid of spacing 360/N which is what ICE-5G was.

	integer :: degree, lat_index, long_index, boundary_index
	double precision :: grid_spacing, latitude, longitude, boundary_latitude, boundary_longitude


	character(len=80) :: dummy

	integer, parameter :: points_unit = 10, gmt_unit = 11
	integer, parameter :: boundary_spacing = 5
	character(len=80), parameter :: points_file = "lat_long_points.txt", gmt_file = "lat_long_poly.gmt"

	call get_command_argument(1,dummy)
	read(dummy,*) degree

	open(file=points_file, unit=points_unit, access="sequential", form="formatted", status="replace")
	open(file=gmt_file, unit=gmt_unit, access="sequential", form="formatted", status="replace")

	
	grid_spacing = 360. / dble(degree)

	do lat_index = 1, degree / 2
		latitude = 90.-(dble(lat_index)-0.5)*grid_spacing
		do long_index = 1, degree
			

			longitude = (dble(long_index)-0.5)*grid_spacing

			write(points_unit,'(F9.5,1X,F9.5)') longitude, latitude
			write(gmt_unit, '(A1,1X,I4)') ">", boundary_spacing*4

			
			do boundary_index = 1, boundary_spacing

				boundary_latitude = 90. - (dble(lat_index) - dble(boundary_index-1) / dble(boundary_spacing)) * grid_spacing
				boundary_longitude = dble(long_index-1) * grid_spacing

				write(gmt_unit,'(F9.5,1X,F9.5)') boundary_longitude, boundary_latitude

			end do

			do boundary_index = 1, boundary_spacing

				boundary_latitude = 90 - dble(lat_index-1) * grid_spacing
				boundary_longitude = (dble(long_index-1) + dble(boundary_index-1) / dble(boundary_spacing))  * grid_spacing 

				write(gmt_unit,'(F9.5,1X,F9.5)') boundary_longitude, boundary_latitude

			end do


			do boundary_index = 1, boundary_spacing

				boundary_latitude = 90. - (dble(lat_index-1) + dble(boundary_index-1) / dble(boundary_spacing)) * grid_spacing
				boundary_longitude = dble(long_index) * grid_spacing

				write(gmt_unit,'(F9.5,1X,F9.5)') boundary_longitude, boundary_latitude

			end do

			do boundary_index = 1, boundary_spacing

				boundary_latitude = 90.0 - dble(lat_index) * grid_spacing
				boundary_longitude = (dble(long_index) - dble(boundary_index-1) / dble(boundary_spacing))  * grid_spacing 

				write(gmt_unit,'(F9.5,1X,F9.5)') boundary_longitude, boundary_latitude

			end do


		end do
	end do
	
	close(unit=points_unit)
	close(unit=gmt_unit)


end program define_sh_grid
