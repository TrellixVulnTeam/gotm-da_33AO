!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: read_chlo
!
! !INTERFACE:
   subroutine read_chlo(unit,jul,secs)
!
! !DESCRIPTION:
!  This routine will provide the Chlorophyll-a values. It
!  is only called if class 12 (Ohlmann & Siegel, 2000) has been specified in {\tt obs.inp}.
!
! !USES:
   use time
   use observations, only : read_obs
   use observations, only : chlo
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: unit,jul,secs
!
! !REVISION HISTORY:
!  Original author(s): Sam Pimentel
!
!  6 Jan 2017: Copied the format from the file read_extinction.f90
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: yy,mm,dd,hh,min,ss
   double precision                  :: t
   double precision, save            :: dt
   integer, save             :: jul1,secs1
   integer, save             :: jul2=0,secs2=0
   double precision, save            :: alpha
   double precision, save            :: obs1(1),obs2(1)=0.
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
         call read_obs(unit,yy,mm,dd,hh,min,ss,1,obs2,rc)
         call julian_day(yy,mm,dd,jul2)
         secs2 = hh*3600 + min*60 + ss
         if(time_diff(jul2,secs2,jul,secs) .gt. 0) EXIT
      end do
      dt = time_diff(jul2,secs2,jul1,secs1)
      alpha = (obs2(1)-obs1(1))/dt
   end if

!  Do the time interpolation
   t  = time_diff(jul,secs,jul1,secs1)

   chlo = obs1(1) + t*alpha

   return
   end subroutine read_chlo
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!----------------------------------------------------------------------- 
