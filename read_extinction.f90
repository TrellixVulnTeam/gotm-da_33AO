!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: read_extinction
!
! !INTERFACE:
   subroutine read_extinction(unit,jul,secs)
!
! !DESCRIPTION:
!  This routine will provide the light extinction coefficients. It
!  is only called if no Jerlov class has been specified in {\tt obs.inp}.
!
! !USES:
   use time
   use observations, only : read_obs
   use observations, only : A,g1,g2
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: unit,jul,secs
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding
!
!  $Log: read_extinction.F90,v $
!  Revision 1.4  2003/03/28 09:20:35  kbk
!  added new copyright to files
!
!  Revision 1.3  2003/03/28 09:02:09  kbk
!  removed tabs
!
!  Revision 1.2  2003/03/10 08:51:58  gotm
!  Improved documentation and cleaned up code
!
!  Revision 1.1.1.1  2001/02/12 15:55:58  gotm
!  initial import into CVS
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: yy,mm,dd,hh,min,ss
   double precision                  :: t
   double precision, save            :: dt
   integer, save             :: jul1,secs1
   integer, save             :: jul2=0,secs2=0
   double precision, save            :: alpha(3)
   double precision, save            :: obs(3),obs1(3),obs2(3)=0.
   integer                   :: rc
!
!-----------------------------------------------------------------------
!BOC
!  This part initialise and read in new values if necessary.
   if(time_diff(jul2,secs2,jul,secs) .lt. 0) then 
      do
         jul1 = jul2
         secs1 = secs2
         obs1 = obs2
         call read_obs(unit,yy,mm,dd,hh,min,ss,3,obs2,rc)
         call julian_day(yy,mm,dd,jul2)
         secs2 = hh*3600 + min*60 + ss
         if(time_diff(jul2,secs2,jul,secs) .gt. 0) EXIT
      end do
      dt = time_diff(jul2,secs2,jul1,secs1)
      alpha = (obs2-obs1)/dt
   end if

!  Do the time interpolation
   t  = time_diff(jul,secs,jul1,secs1)

   obs = obs1 + t*alpha 

   A = obs(1)
   g1 = obs(2)
   g2 = obs(3)

   return
   end subroutine read_extinction
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!----------------------------------------------------------------------- 
