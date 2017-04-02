#$Id: Makefile.stable_netcdf,v 1.7 2003/03/28 09:27:56 kbk Exp $
#
# Master Makefile for making the GOTM executable.
#

.SUFFIXES:
.SUFFIXES: .f90

SHELL	= /bin/sh


# Set up the path to the NetCDF library - very important.

#NETCDFINCDIR	= ./netcdf-3.6.2/libsrc/
#/users/zxb/netcdf/netcdf-350/src/f90/netcdf.mod
NETCDFINCDIR = /usr/include

NETCDFLIB = libnetcdf.a # Build it and copy it to our working folder
#/usr/lib/libnetcdf.a


#NAG F95 compiler for Linux
#FC     = f95nag
#FFLAGS = -f77 -I$(NETCDFINCDIR)

#Fujitsu F95 compiler for Linux
#FC     = f95
#FFLAGS = -Am -fw -I$(NETCDFINCDIR)

#DECFOR F95 compiler for OSF1 - alpha
#FC    = f95
#FFLAGS = -I$(NETCDFINCDIR)

#Intel Fortran  compiler for 
#FC    = ifort
#FFLAGS=-g -fbacktrace -ffpe-trap=zero,overflow,underflow
#FFLAGS=-g -fbacktrace -ffpe-trap=overflow,underflow
FC=gfortran
FFLAGS=-g -fbacktrace
## No more need.
#FFLAGS = -I$(NETCDFINCDIR)

#Mac Fortran  compiler for 
#FC    = gfortran
#FFLAGS = -I$(NETCDFINCDIR)

#sun fortran compiler
#FC = f90
#FFLAGS = -I$(NETCDFINCDIR)

MODULES	= \
libutil.a(time.o)			\
libutil.a(tridiagonal.o)		\
libutil.a(eqstate.o)			\
libobservations.a(observations.o)	\
libmeanflow.a(meanflow.o)		\
libairsea.a(airsea.o)			\
libturbulence.a(turbulence.o)		\
liboutput.a(asciiout.o)			\
liboutput.a(ncdfout.o)			\
liboutput.a(output.o)			\
libturbulence.a(sediment.o)		\
libturbulence.a(seagrass.o)


UTIL	= \
libutil.a(advection.o)		\
libutil.a(w_split_it_adv.o)	\
libutil.a(gridinterpol.o)	\
libutil.a(yevol.o)

MEANFLOW	= \
libmeanflow.a(updategrid.o)		\
libmeanflow.a(adaptivegrid.o)		\
libmeanflow.a(coriolis.o)		\
libmeanflow.a(uequation.o)		\
libmeanflow.a(vequation.o)		\
libmeanflow.a(extpressure.o)		\
libmeanflow.a(intpressure.o)		\
libmeanflow.a(friction.o)		\
libmeanflow.a(temperature.o)		\
libmeanflow.a(salinity.o)		\
libmeanflow.a(stratification.o)		\
libmeanflow.a(buoyancy.o)		\
libmeanflow.a(convectiveadjustment.o)	\
libmeanflow.a(production.o)

TURBULENCE   = \
libturbulence.a(tkeeq.o)		\
libturbulence.a(q2over2eq.o)		\
libturbulence.a(lengthscaleeq.o)	\
libturbulence.a(dissipationeq.o)	\
libturbulence.a(genericeq.o)		\
libturbulence.a(tkealgebraic.o)		\
libturbulence.a(algebraiclength.o)	\
libturbulence.a(ispralength.o)		\
libturbulence.a(potentialml.o)		\
libturbulence.a(cmue_bb.o)		\
libturbulence.a(cmue_bbqe.o)		\
libturbulence.a(cmue_ca.o)		\
libturbulence.a(cmue_caqe.o)		\
libturbulence.a(cmue_cb.o)		\
libturbulence.a(cmue_cbqe.o)		\
libturbulence.a(cmue_kc.o)		\
libturbulence.a(cmue_kcqe.o)		\
libturbulence.a(cmue_my.o)		\
libturbulence.a(cmue_gpqe.o)		\
libturbulence.a(cmue_ma.o)		\
libturbulence.a(cmue_sg.o)		\
libturbulence.a(cmue_rf.o)		\
libturbulence.a(fk_craig.o)		\
libturbulence.a(turbulence_adv.o)	\
libturbulence.a(gotm.o)
#libturbulence.a(gotm_lib_version.o)

OBSERVATIONS   = \
libobservations.a(analytical_profile.o)	\
libobservations.a(get_eps_profile.o)	\
libobservations.a(get_ext_pressure.o)	\
libobservations.a(get_int_pressure.o)	\
libobservations.a(get_s_profile.o)	\
libobservations.a(get_t_profile.o)	\
libobservations.a(get_vel_profile.o)	\
libobservations.a(get_w_adv.o)	\
libobservations.a(get_zeta.o)	\
libobservations.a(read_extinction.o)	\
libobservations.a(read_chlo.o)	\


LIBS	=	libairsea.a		\
		libturbulence.a 	\
		libmeanflow.a 		\
		libobservations.a	\
		liboutput.a		\
		libutil.a		

all: gotm 

gotm: $(MODULES) $(LIBS) $(NETCDFLIB) main.o
	$(FC) main.o -o $@ gotm.o $(LIBS) $(NETCDFLIB)
	-rm main.o

main.o: gotm.o

modules: $(MODULES)

libairsea.a: $(AIRSEA)

libturbulence.a: $(TURBULENCE)

libutil.a: $(UTIL)

libmeanflow.a: $(MEANFLOW)

libobservations.a: $(OBSERVATIONS)

libnetcdf.a: 	
	# These commands needs to be chained together, and must end with
	# backslash for MAKE to know it is one single command.
	cd ./netcdf-3.6.2 && ./configure && \
	make && \
	cp ./libsrc/.libs/libnetcdf.a .. && \
	make distclean && \
	cd ..

clean:
	-rm -f lib*.a  *.mod *.o

realclean: clean
	-rm -f gotm 

%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@

