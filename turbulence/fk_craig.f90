!-----------------------------------------------------------------------
!BOP
!
! !ROUTINE: TKE flux from wave--breaking \label{sec:fkCraig}
! 
! !INTERFACE:
   double precision  function fk_craig(u_tau)
!
! !DESCRIPTION:
! This functions returns the flux of $k$ caused by breaking surface waves
! according to 
! \begin{equation}
!  \label{craig}
!   F_k = \eta u_*^3
!  \point
! \end{equation}
! This form has also been used by \cite{CraigBanner94}, who suggested
! $\eta \approx 100$.
! 
! !USES:
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   double precision, intent(in)                :: u_tau
!
! !DEFINED PARAMETERS:
   double precision, parameter                 :: eta=100.
!
! !REVISION HISTORY: 
!  Original author(s): Lars Umlauf
!
!  $Log: fk_craig.F90,v $
!  Revision 1.2  2003/03/28 09:20:35  kbk
!  added new copyright to files
!
!  Revision 1.1  2003/03/10 09:00:36  gotm
!  Part of new generic turbulence model
!
! 
!EOP
!-----------------------------------------------------------------------
!BOC
   fk_craig = eta*u_tau**3.

   end function fk_craig
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!----------------------------------------------------------------------- 
