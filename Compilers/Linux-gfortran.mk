# svn $Id$
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Copyright (c) 2002-2018 The ROMS/TOMS Group                           :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.txt                                                :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
# Include file for GNU Fortran compiler on Linux
# -------------------------------------------------------------------------
#
# ARPACK_LIBDIR  ARPACK libary directory
# FC             Name of the fortran compiler to use
# FFLAGS         Flags to the fortran compiler
# CPP            Name of the C-preprocessor
# CPPFLAGS       Flags to the C-preprocessor
# CC             Name of the C compiler
# CFLAGS         Flags to the C compiler
# CXX            Name of the C++ compiler
# CXXFLAGS       Flags to the C++ compiler
# CLEAN          Name of cleaning executable after C-preprocessing
# NF_CONFIG      NetCDF Fortran configuration script
# NETCDF_INCDIR  NetCDF include directory
# NETCDF_LIBDIR  NetCDF library directory
# NETCDF_LIBS    NetCDF library switches
# LD             Program to load the objects into an executable
# LDFLAGS        Flags to the loader
# RANLIB         Name of ranlib command
# MDEPFLAGS      Flags for sfmakedepend
#
# First the defaults
#
               FC := gfortran
           FFLAGS := -frepack-arrays
              CPP := /usr/bin/cpp
         CPPFLAGS := -P -traditional
               CC := gcc
              CXX := g++
           CFLAGS :=
         CXXFLAGS :=
          LDFLAGS :=
               AR := ar
          ARFLAGS := -r
            MKDIR := mkdir -p
               RM := rm -f
           RANLIB := ranlib
             PERL := perl
             TEST := test

        MDEPFLAGS := --file=- --objdir=$(SCRATCH_DIR)
#        MDEPFLAGS := --cpp --fext=f90 --file=- --objdir=$(SCRATCH_DIR)

#
# Library locations, can be overridden by environment variables.
#

ifdef USE_NETCDF4
        NF_CONFIG ?= nf-config
    NETCDF_INCDIR ?= $(shell $(NF_CONFIG) --includedir)
             LIBS := $(shell $(NF_CONFIG) --flibs)
else
    NETCDF_INCDIR ?= /usr/local/include
    NETCDF_LIBDIR ?= /usr/local/lib
      NETCDF_LIBS ?= -lnetcdf
             LIBS := -L$(NETCDF_LIBDIR) $(NETCDF_LIBS)
endif

ifdef USE_ARPACK
 ifdef USE_MPI
   PARPACK_LIBDIR ?= /opt/gfortransoft/PARPACK
             LIBS += -L$(PARPACK_LIBDIR) -lparpack
 endif
    ARPACK_LIBDIR ?= /opt/gfortransoft/PARPACK
             LIBS += -L$(ARPACK_LIBDIR) -larpack
endif

ifdef USE_MPI
         CPPFLAGS += -DMPI
 ifdef USE_MPIF90
               FC := mpif90
 endif
endif

ifdef USE_OpenMP
         CPPFLAGS += -D_OPENMP
endif

ifdef USE_DEBUG
         CPPFLAGS += -DUSE_DEBUG
           FFLAGS += -g -fbounds-check -fbacktrace
           FFLAGS += -finit-real=nan -ffpe-trap=invalid,zero,overflow
           CFLAGS += -g
         CXXFLAGS += -g
else
           FFLAGS += -O3 -ffast-math -ffpe-trap=invalid,zero -ffree-line-length-none
           CFLAGS += -O3
         CXXFLAGS += -O3
endif

ifdef USE_MCT
       MCT_INCDIR ?= /usr/local/mct/include
       MCT_LIBDIR ?= /usr/local/mct/lib
           FFLAGS += -I$(MCT_INCDIR)
             LIBS += -L$(MCT_LIBDIR) -lmct -lmpeu
endif

ifdef USE_MPI
           FFLAGS += -I/usr/include
endif

ifdef USE_ESMF
          ESMF_OS ?= $(OS)
      ESMF_SUBDIR := $(ESMF_OS).$(ESMF_COMPILER).$(ESMF_ABI).$(ESMF_COMM).$(ESMF_SITE)
      ESMF_MK_DIR ?= $(ESMF_DIR)/lib/lib$(ESMF_BOPT)/$(ESMF_SUBDIR)
                     include $(ESMF_MK_DIR)/esmf.mk
           FFLAGS += $(ESMF_F90COMPILEPATHS)
             LIBS += $(ESMF_F90LINKPATHS) $(ESMF_F90ESMFLINKLIBS)
endif

ifdef USE_CXX
             LIBS += -lstdc++
endif
ifdef USE_FFTW
           FFLAGS += $(shell pkg-config --cflags fftw3)
             LIBS += $(shell pkg-config --libs fftw3)
endif

#
# Use full path of compiler.
#
               FC := $(shell which ${FC})
               LD := $(FC)

#
# Turn off bounds checking for function def_var, as "dimension(*)"
# declarations confuse Gnu Fortran 95 bounds-checking code.
#

$(SCRATCH_DIR)/def_var.o: FFLAGS += -fno-bounds-check

#
# Allow integer overflow in ran_state.F.  This is not allowed
# during -O3 optimization. This option should be applied only for
# Gfortran versions >= 4.2.
#

FC_TEST := $(findstring $(shell ${FC} --version | head -1 | \
                              awk '{ sub("Fortran 95", "Fortran"); print }' | \
                              cut -d " " -f 4 | \
                              cut -d "." -f 1-2), \
             4.0 4.1)

#ifeq "${FC_TEST}" ""
#$(SCRATCH_DIR)/ran_state.o: FFLAGS += -fno-strict-overflow
#endif

#
# Set free form format in source files to allow long string for
# local directory and compilation flags inside the code.
#

#$(SCRATCH_DIR)/mod_ncparam.o: FFLAGS += -ffree-form -ffree-line-length-none
#$(SCRATCH_DIR)/mod_strings.o: FFLAGS += -ffree-form -ffree-line-length-none
#$(SCRATCH_DIR)/analytical.o: FFLAGS += -ffree-form -ffree-line-length-none
$(SCRATCH_DIR)/ran_state.o: FFLAGS += -fno-strict-overflow
$(SCRATCH_DIR)/mod_ncparam.o: FFLAGS += -ffree-form
$(SCRATCH_DIR)/mod_strings.o: FFLAGS += -ffree-form
$(SCRATCH_DIR)/analytical.o: FFLAGS += -ffree-form
$(SCRATCH_DIR)/biology.o: FFLAGS += -ffree-form -ffree-line-length-none
ifdef USE_ADJOINT
$(SCRATCH_DIR)/ad_biology.o: FFLAGS += -ffree-form -ffree-line-length-none
endif
ifdef USE_REPRESENTER
$(SCRATCH_DIR)/rp_biology.o: FFLAGS += -ffree-form -ffree-line-length-none
endif
ifdef USE_TANGENT
$(SCRATCH_DIR)/tl_biology.o: FFLAGS += -ffree-form -ffree-line-length-none
endif
ifdef BIO_COBALT
$(SCRATCH_DIR)/mod_biology.mod: FFLAGS += -ffree-form -ffree-line-length-none -std=f2003
$(SCRATCH_DIR)/mod_biology.o: FFLAGS += -ffree-form -ffree-line-length-none -std=f2003
$(SCRATCH_DIR)/biology_mod.mod: FFLAGS += -ffree-form -ffree-line-length-none -std=f2003
$(SCRATCH_DIR)/biology.o: FFLAGS += -ffree-form -ffree-line-length-none -std=f2003 -pedantic
endif

#
# Supress free format in SWAN source files since there are comments
# beyond column 72.
#

ifdef USE_SWAN

$(SCRATCH_DIR)/ocpcre.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/ocpids.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/ocpmix.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swancom1.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swancom2.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swancom3.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swancom4.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swancom5.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swanmain.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swanout1.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swanout2.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swanparll.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swanpre1.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swanpre2.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swanser.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swmod1.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/swmod2.o: FFLAGS += -ffixed-form
$(SCRATCH_DIR)/m_constants.o: FFLAGS += -ffree-form -ffree-line-length-none
$(SCRATCH_DIR)/m_fileio.o: FFLAGS += -ffree-form -ffree-line-length-none
$(SCRATCH_DIR)/mod_xnl4v5.o: FFLAGS += -ffree-form -ffree-line-length-none
$(SCRATCH_DIR)/serv_xnl4v5.o: FFLAGS += -ffree-form -ffree-line-length-none

endif
