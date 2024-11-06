FC = ifort

#FCFLAGS = -g -fbacktrace -fbounds-check 
FCFLAGS = -O2

# if compiling with the Intel Fortran compiler, you need to add an extra flag
FCFLAGS = -O2 -assume byterecl

objfiles =  global_parameters.o grids.o read_icefile.o  find_flowline_fisher_adaptive_4.o flowline_location.o 

NFDIR = /usr

define_sh_grid: define_sh_grid.f90
	$(FC) -o define_sh_grid $(FCFLAGS) define_sh_grid.f90

grid_creation: grid_creation.f90 hexagon_grid.o
	$(FC) -o grid_creation $(FCFLAGS) grid_creation.f90 hexagon_grid.o

hexagon_grid.o: hexagon_grid.f90
	$(FC) -o hexagon_grid.o $(FCFLAGS) -c hexagon_grid.f90

overlapping_polygon.o: overlapping_polygon.f90
	$(FC) -o overlapping_polygon.o $(FCFLAGS) -c overlapping_polygon.f90

test_overlap: test_overlap.f90 hexagon_grid.o overlapping_polygon.o
	$(FC) -o test_overlap $(FCFLAGS) test_overlap.f90 hexagon_grid.o overlapping_polygon.o


create_disc_file: create_disc_file.f90 hexagon_grid.o overlapping_polygon.o
	$(FC) -o create_disc_file $(FCFLAGS)  create_disc_file.f90  hexagon_grid.o overlapping_polygon.o


fakegrid: fakegrid.f90 hexagon_grid.o overlapping_polygon.o
	$(FC) -o fakegrid $(FCFLAGS)  fakegrid.f90 hexagon_grid.o overlapping_polygon.o


realgrid: realgrid.f90  hexagon_grid.o overlapping_polygon.o
	$(FC) -o realgrid $(FCFLAGS) realgrid.f90  hexagon_grid.o overlapping_polygon.o

tegmarkgrid: tegmarkgrid.f90  hexagon_grid.o overlapping_polygon.o
	$(FC) -o tegmarkgrid $(FCFLAGS) tegmarkgrid.f90  hexagon_grid.o overlapping_polygon.o

selen_ice_input: selen_ice_input.f90
	$(FC) -o selen_ice_input $(FCFLAGS) selen_ice_input.f90
