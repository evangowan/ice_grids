program selen_ice_input

	implicit none

type disc

	double precision :: longitude, latitude, radius

end type disc



	character(len=80), parameter :: out_file = "selen_ice_input.disc"
	integer, parameter :: out_unit = 10, ice_unit=20, points_unit = 30

	character(len=80) :: dummy, points_file, ice_file, format_out
	double precision :: latitude, longitude, diameter, thickness

	integer :: n, counter, istat, number_times, time, disc_number, counter2, resolution
	integer :: old_time, time_interval
	type(disc), dimension(:), allocatable :: disc_store

	double precision, dimension(:,:), allocatable :: ice_store

	call get_command_argument(1,dummy)
	read(dummy,*) resolution

	call get_command_argument(2,dummy)
	read(dummy,*) old_time

	call get_command_argument(3,dummy)
	read(dummy,*) time_interval

	n = 20*(2*resolution*(resolution-1)) + 12 ! number of points

	! allocate points

	allocate(disc_store(n))


	write(points_file,*) resolution

	points_file = "tegmark/points_" // trim(adjustl(points_file)) // ".txt"

	open(unit=points_unit, file=points_file, access="sequential", form="formatted", status="old")

	do counter = 1, n

		read(points_unit,*,iostat=istat) longitude, latitude, diameter ! diameter is in km
		if(istat /= 0) THEN
			write(6,*) "probably using the wrong resolution file, aborting"
			stop
		endif

		disc_store(counter)%latitude = latitude
		if(longitude < 0) THEN
			disc_store(counter)%longitude = 360. + longitude
		else
			disc_store(counter)%longitude = longitude
		endif

		disc_store(counter)%radius = diameter / 2.0 / 111.195 ! the distance of 1 degree latitude in km if the radius of the Earth is 6,371
	end do

	close(points_unit)

	number_times = old_time / time_interval + 1 ! zero is a number!

	! read in the discs

	allocate(ice_store(n,number_times))
	ice_store = 0.0

	do counter = 1, number_times

		! open the ice files

		time = (counter-1) * time_interval

		write(ice_file,*) time

		ice_file = "ice_temp/" // trim(adjustl(ice_file)) // ".txt"

		open(unit=ice_unit, file=ice_file, access="sequential", form="formatted", status="old")

		read_ice: do

			read(ice_unit,*,iostat=istat) disc_number, thickness
			if(istat /= 0) THEN
				exit read_ice
			endif

			ice_store(disc_number,counter) = ice_store(disc_number,counter) +  thickness ! just to be safe, have it be additive

		end do read_ice


		close(ice_unit)


	end do


	! output

	open(unit=out_unit, file=out_file, access="sequential", form="formatted", status="replace")

	! format

	write(format_out,*) number_times

	format_out = "(I8,1X,F10.6,1X,F10.6,1X,F10.7,1X," // trim(adjustl(format_out)) // "(F6.1,1X))"

	do counter = 1, n
!       		Read (10,*)  longc(i), latic(i), alfa(i), (cr(k),k=nn,0,-1)


		if( sum(ice_store(counter,:),1) > 0.0) THEN
			write(out_unit,format_out) counter, disc_store(counter)%longitude, disc_store(counter)%latitude, disc_store(counter)%radius, &
			  (ice_store(counter,counter2), counter2=number_times,1,-1)
		endif

	end do

	close(out_unit)

	deallocate(disc_store,ice_store)

end program selen_ice_input
