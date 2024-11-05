FC = ifort

FCFLAGS = -g -fbacktrace -fbounds-check 
FCFLAGS = -O2

# if compiling with the Intel Fortran compiler, you need to add an extra flag
FCFLAGS = -O2 -assume byterecl

objfiles =  global_parameters.o grids.o read_icefile.o  find_flowline_fisher_adaptive_4.o flowline_location.o 

NFDIR = /usr

icosahedron: icosahedron.f 
	$(FC) -o icosahedron $(FCFLAGS) icosahedron.f


hex_grid: hex_grid.f90 
	$(FC) -o hex_grid $(FCFLAGS) hex_grid.f90

formatted_files: formatted_files.f90
	$(FC) -o formatted_files $(FCFLAGS) formatted_files.f90
