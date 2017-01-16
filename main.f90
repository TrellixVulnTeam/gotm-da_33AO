
!-----------------------------------------------------------------------
!BOP
!
! !ROUTINE: GOTM --- the main program  \label{sec:main}
! 
! !INTERFACE:
   program main 
!
! !DESCRIPTION: 
! This is the main program of GOTM. However, because GOTM has been programmed
! in a modular way, this routine is very short and merely calls internal 
! routines of other modules. Its main purpose is to update the time and to
! call the internal routines {\tt init\_gotm()}, {\tt time\_loop()}, and 
! {\tt clean\_up()}, which are defined in the module {\tt gotm} as discussed in 
! \sect{sec:gotm}.
!
! !USES:
   use time
   use gotm

   IMPLICIT NONE
! 
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  $Log: main.F90,v $
!  Revision 1.5  2003/03/28 09:20:34  kbk
!  added new copyright to files
!
!  Revision 1.4  2003/03/10 09:20:28  gotm
!  Added new Generic Turbulence Model + improved documentation and cleaned up code
!
!  Revision 1.3  2001/11/18 13:07:06  gotm
!  Cleaned
!
!  Revision 1.3  2001/09/19 08:26:08  gotm
!  Only calls CPU_time() if -DFORTRAN95
!
!  Revision 1.2  2001/05/31 12:00:52  gotm
!  Correction in the calculation of the shear squared calculation - now according
!  to Burchard 1995 (Ph.D. thesis).
!  Also some cosmetics and cleaning of Makefiles.
!
!  Revision 1.1.1.1  2001/02/12 15:55:59  gotm
!  initial import into CVS
!
!EOP
!
! !LOCAL VARIABLES:
   character(LEN=8)          :: datestr
   real                      :: t1=-1,t2=-1
!
!-----------------------------------------------------------------------
!BOC
   !SP - This is time of model run
   call Date_And_Time(datestr,timestr)
   write(0,*) "------------------------------------------------------------------------" 
   write(0,*) 'GOTM ver. ',"3.0.0",': Started on  ',datestr,' ',timestr
   write(0,*) "------------------------------------------------------------------------"

   call init_gotm()
   call time_loop()
   call clean_up()


   call Date_And_Time(datestr,timestr)
   write(0,*) "------------------------------------------------------------------------"
   write(0,*) 'GOTM ver. ',"3.0.0",': Finished on ',datestr,' ',timestr

   write(0,*) "------------------------------------------------------------------------"
   write(0,*) "------------------------------------------------------------------------"

   end
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!----------------------------------------------------------------------- 
