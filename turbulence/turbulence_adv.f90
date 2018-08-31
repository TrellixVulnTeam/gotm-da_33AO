!-----------------------------------------------------------------------
!BOP
!
! !ROUTINE: Vertical advection for  turbulence variables \label{sec:turbulenceAdv}
! 
! !INTERFACE:
   subroutine turbulence_adv(N,dt,h)

! !DESCRIPTION: 
! In this subroutine, the vertical advection of turbulence either due to
! prescribed vertical physical velocity or due to moving coordinates is
! carried out for the prognostically calculated length-scale related
! quantities. 
!
! !USES:
   use turbulence,   only: tke,eps,L,k_min,eps_min,cde
   use turbulence,   only: tke_method,tke_keps,tke_MY,diss_eq,length_eq
   use turbulence,   only: generic_eq,len_scale_method
   use observations, only: w_adv_discr,w_adv_method
   use meanflow,     only: w,ho,grid_method,w_grid
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: N
   double precision, intent(in)                :: dt
   double precision, intent(in)                :: h(0:N)
!
! !REVISION HISTORY: 
!  Original author(s): Hans Burchard
!
!  $Log: turbulence_adv.F90,v $
!  Revision 1.4  2003/03/28 09:20:35  kbk
!  added new copyright to files
!
!  Revision 1.3  2003/03/28 08:37:27  kbk
!  removed tabs
!
!  Revision 1.2  2003/03/10 09:05:02  gotm
!  Fixed comment char
!
!  Revision 1.1  2003/03/10 09:00:36  gotm
!  Part of new generic turbulence model
!
! 
! !LOCAL VARIABLES:
   integer                   :: i
   logical                   :: surf_flux,bott_flux
   double precision                  :: h_t(0:N),ho_t(0:N)
   double precision                  :: w_t(0:N),w_grid_t(0:N)
   double precision                  :: l_min
!
!EOP
!-----------------------------------------------------------------------
!BOC

   l_min = cde*k_min**1.5/eps_min

   surf_flux=.false.
   bott_flux=.false.

   if (w_adv_method .ne. 0) then
      do i=1,N-1
         h_t(i)=0.5*(h(i)+h(i+1))
         ho_t(i)=0.5*(ho(i)+ho(i+1))
         w_t(i)=0.5*(w(i)+w(i+1))
      end do
      w_t(0)=0.
      w_t(N)=0.
      if ((tke_method.eq.tke_keps).or.(tke_method.eq.tke_MY)) &
         call w_split_it_adv(N-1,dt,h_t,ho_t,tke,w_t,w_adv_discr, &
                             surf_flux,bott_flux,1)
      if (len_scale_method.eq.diss_eq)  &
         call w_split_it_adv(N-1,dt,h_t,ho_t,eps,w_t,w_adv_discr, &
                             surf_flux,bott_flux,1)
      if ((len_scale_method.eq.length_eq).or.(len_scale_method.eq.generic_eq)) &
         call w_split_it_adv(N-1,dt,h_t,ho_t,L,w_t,w_adv_discr, &
                             surf_flux,bott_flux,1)
   end if

   if (grid_method .ne. 0) then
      do i=1,N-1
         h_t(i)=0.5*(h(i)+h(i+1))
         ho_t(i)=0.5*(ho(i)+ho(i+1))
         w_grid_t(i)=0.5*(w_grid(i)+w_grid(i+1))
      end do
      w_grid_t(0)=0.
      w_grid_t(N)=0.
      if ((tke_method.eq.tke_keps).or.(tke_method.eq.tke_MY)) &
         call w_split_it_adv(N-1,dt,h_t,ho_t,tke,w_grid_t,w_adv_discr, &
                             surf_flux,bott_flux,2)
      if (len_scale_method.eq.diss_eq)  &
         call w_split_it_adv(N-1,dt,h_t,ho_t,eps,w_grid_t,w_adv_discr, &
                             surf_flux,bott_flux,2)
      if ((len_scale_method.eq.length_eq).or.(len_scale_method.eq.generic_eq)) &
         call w_split_it_adv(N-1,dt,h_t,ho_t,L,w_grid_t,w_adv_discr, &
                             surf_flux,bott_flux,2)
   end if

   do i=1,N-1
      if ((tke(i) .le. 0) .or. (eps(i) .le. 0) .or. (L(i) .le. 0)) then
         write(0,*) 'One of the turbulent quantities became negative'
         write(0,*) 'due to the vertical advection. These quantities '
         write(0,*) 'have been set to the minimum values and the'
         write(0,*) 'execution of the program is continued.'
         tke(i)=k_min
         eps(i)=eps_min
         L(i)=l_min
      end if
  end do

   return
   end subroutine turbulence_adv
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!----------------------------------------------------------------------- 
