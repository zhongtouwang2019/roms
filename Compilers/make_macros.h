/*
** svn $Id: make_macros.h 975 2009-05-05 22:51:13Z kate $
********************************************************** Hernan G. Arango ***
** Copyright (c) 2002-2009 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**                                                                           **
** This configuration file defines several macros used by the makefile to    **
** select the appropriate code to compile and link. These macros are used    **
** to exclude files from the "modules" and "includes" definitions.           **
**                                                                           **
*******************************************************************************
*/

#include "../ROMS/Include/cppdefs.h"

/*
** Process adjoint model.
*/

#ifdef ADJOINT
  USE_ADJOINT := on
#else
  USE_ADJOINT :=
#endif

/*
** Process tangent linear model.
*/

#ifdef TANGENT
  USE_TANGENT := on
#else
  USE_TANGENT :=
#endif

/*
** Process representers tangent linear model.
*/

#ifdef TL_IOMS
  USE_REPRESENTER := on
#else
  USE_REPRESENTER :=
#endif

/*
** Process Sea Ice model.
*/

#ifdef ICE_MODEL
  USE_SEAICE := on
#else
  USE_SEAICE :=
#endif

/*
** Process WRF Atmospheric model.
*/

#ifdef WRF_COUPLING
  USE_WRF := on
#else
  USE_WRF :=
#endif

/*
** Process SWAN wave model.
*/

#ifdef SWAN_COUPLING
  USE_SWAN := on
#else
  USE_SWAN :=
#endif

/*
** Process REFDIF wave model.
*/

#ifdef REFDIF_COUPLING
  USE_REFDIF := on
#else
  USE_REFDIF :=
#endif

/*
** Determine if the ARPACK library is needed.
*/

#if defined PROPAGATOR || defined W4DPSAS ||  defined W4DVAR || \
    defined IS4DVAR    || defined W4DPSAS_SENSITIVITY        || \
    defined TL_W4DPSAS || defined W4DVAR_SENSITIVITY         || \
    defined TL_W4DVAR
  USE_ARPACK := on
#else
  USE_ARPACK :=
#endif

/*
** Determine if the Model Coupling Tool library is needed.
*/

#ifdef MCT_LIB
  USE_MCT := on
#else
  USE_MCT :=
#endif

/*
** Determine if the Earth System Modeling Framework library is needed.
*/

#ifdef ESMF_LIB
  USE_ESMF := on
#else
  USE_ESMF :=
#endif

/*
** Compile the Fish directory.
*/

#ifdef NEMURO_SAN
  USE_FISH := on
#else
  USE_FISH :=
#endif
