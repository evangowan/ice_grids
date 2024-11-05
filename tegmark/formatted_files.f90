program formatted_files


	implicit none

	type polygon

		integer :: number_points
		double precision, dimension(6) :: polygon_corners_latitude
		double precision, dimension(6) :: polygon_corners_longitude

	end type polygon

	type pixel

		double precision :: longitude, latitude, radius
		integer :: hexagon_number, latitude_number
		

	end type pixel

	type pixel_lat

		double precision :: latitude
		integer :: start_number, end_number

	end type pixel_lat

	character(len=80), parameter :: polygon_file = "hexagons.gmt", points_file = "points_sorted.txt"
	integer, parameter :: polygon_unit = 10, point_unit = 11, out_unit = 12
	type(pixel), allocatable, dimension(:) :: pixel_list
	type(polygon), allocatable, dimension(:) :: polygon_list
	type(pixel_lat), allocatable, dimension(:) :: pixel_lat_list
	character(len=80) ::  muncher, out_file, resolution_text
	integer :: n, resolution, counter, istat, polygon_number, number_points, latitude_number, start_number, end_number, i, counter2
	double precision :: current_latitude


	call get_command_argument(1,resolution_text)
	read(resolution_text,*) resolution
	n = 20*(2*resolution*(resolution-1)) + 12 ! number of points

	write(6,*) n

	allocate(pixel_list(n),polygon_list(n),pixel_lat_list(n))

	open(unit=point_unit, file=points_file, access="sequential", form="formatted", status="old")
	open(unit=polygon_unit, file=polygon_file, access="sequential", form="formatted", status="old")

	! read sorted points file

	latitude_number = 0
	current_latitude = -91.0

	do counter = 1, n, 1
		read(point_unit, *) pixel_list(counter)%longitude, pixel_list(counter)%latitude, pixel_list(counter)%radius, &
			   				pixel_list(counter)%hexagon_number

		if ( pixel_list(counter)%latitude > current_latitude ) THEN
			latitude_number = latitude_number + 1
			current_latitude = pixel_list(counter)%latitude
		end if

		if (pixel_list(counter)%longitude < 0.0) THEN
			pixel_list(counter)%longitude = pixel_list(counter)%longitude + 360.0
		end if

		 pixel_list(counter)%latitude_number = latitude_number
	end do


	! write the pixel file

	out_file = 'px-R' // trim(adjustl(resolution_text)) // '.dat'

	open(unit=out_unit, file=out_file, access="sequential", form="formatted", status="replace")
	write(6,*) out_file


	do counter = 1, n, 1

		write(out_unit,'(F11.6,1X,F11.6,1X,I8,1X,I8)') pixel_list(counter)%longitude, pixel_list(counter)%latitude, pixel_list(counter)%latitude_number, counter
	end do
	close(unit=out_unit)

	! find the latitudes for the pixel latitude file

	latitude_number = 0
	do counter = 1, n, 1

		if (pixel_list(counter)%latitude_number > latitude_number) then

			pixel_lat_list(pixel_list(counter)%latitude_number)%start_number = counter
			pixel_lat_list(pixel_list(counter)%latitude_number)%latitude = pixel_list(counter)%latitude
			latitude_number = pixel_list(counter)%latitude_number

		end if

		pixel_lat_list(pixel_list(counter)%latitude_number)%end_number = counter

	end do

	! write out pixel latitude file

	out_file = 'px-lat-R' // trim(adjustl(resolution_text)) // '.dat'

	open(unit=out_unit, file=out_file, access="sequential", form="formatted", status="replace")
	write(6,*) out_file

	do counter = 1, pixel_list(n)%latitude_number, 1


		write(out_unit,'(I8,1X,F11.6,1X,I8,1X,I8)') counter, pixel_lat_list(counter)%latitude, &
				  pixel_lat_list(counter)%start_number,  pixel_lat_list(counter)%end_number

	end do

	close(unit=out_unit)

	! read in the unsorted polygons

	read_polygons: do 
		read(polygon_unit, *, iostat=istat) muncher, number_points, polygon_number
		if(istat /= 0) then
			exit read_polygons
		end if

		polygon_list(polygon_number)%number_points = number_points

		do counter = 1, number_points, 1
			read(polygon_unit, *) polygon_list(polygon_number)%polygon_corners_longitude(counter), &
			  					  polygon_list(polygon_number)%polygon_corners_latitude(counter)

		end do

	end do read_polygons

	! write out the sorted polygons

	out_file = 'hexagons_' // trim(adjustl(resolution_text)) // '.gmt'

	open(unit=out_unit, file=out_file, access="sequential", form="formatted", status="replace")
	write(6,*) out_file


	do counter = 1, n, 1

		i = pixel_list(counter)%hexagon_number

		write(out_unit,'(A1,1X,I7)') '>', polygon_list(i)%number_points

		do counter2 = 1, polygon_list(i)%number_points
			write(out_unit,*)  polygon_list(i)%polygon_corners_longitude(counter2), &
							   polygon_list(i)%polygon_corners_latitude(counter2)
		end do

	end do

	close(unit=out_unit)

	close(unit=point_unit)
	close(unit=polygon_unit)

end program formatted_files
