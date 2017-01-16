!-----------------------------------------------------------------------
!BOP
!
! !ROUTINE: The tracer advection-diffusion equation \label{sec:yevol}
! 
! !INTERFACE:
   subroutine yevol(N,Bcup,Bcdw,dt,cnpar,Yup,Ydw,Taur,h,ho,avh,w,Qsour, &
                    Yobs,w_adv_method,w_adv_discr,Y,surf_flux,bott_flux, &
                    grid_method,w_grid,flag)
! !DESCRIPTION:
!  This general tracer advection-diffusion routine
!  computes the evolution of any tracer variable $Y$ 
!  including sources, sinks and internal restoring. The advection 
!  methods are described in \sect{sec:advection}. At the end,
!  the tri-diagonal matrix solver described in \sect{sec:tridiagonal} is called.
!  {\tt yevol()} is used in
!  {\tt temperature.F90}, {\tt salinity.F90}, {\tt buoyancy.F90} and
!  {\tt sediment.F90}.
!
! !USES:
   use mtridiagonal
!
! !INPUT PARAMETERS:
   integer,  intent(in)                :: N,grid_method,w_adv_discr,flag
   integer,  intent(in)                :: Bcup,Bcdw,w_adv_method
   double precision, intent(in)                :: dt,cnpar
   double precision, intent(in)                :: Yup,Ydw
   double precision, intent(in)                :: Taur(0:N)
   double precision, intent(in)                :: h(0:N),ho(0:N),avh(0:N)
   double precision, intent(in)                :: w(0:N),Qsour(0:N),w_grid(0:N)
   double precision, intent(in)                :: Yobs(0:N)
   logical,  intent(in)                :: surf_flux,bott_flux
!
! !OUTPUT PARAMETERS:
   double precision, intent(out)               :: Y(0:N)
!
! !REVISION HISTORY: 
!  Original author(s): Pierre-Philippe Mathieu
!
!  $Log: yevol.F90,v $
!  Revision 1.5  2003/03/28 09:20:36  kbk
!  added new copyright to files
!
!  Revision 1.4  2003/03/28 09:10:39  kbk
!  removed tabs
!
!  Revision 1.3  2003/03/10 08:54:16  gotm
!  Improved documentation and cleaned up code
!
!  Revision 1.2  2001/11/27 19:49:48  gotm
!  Added higher order advection via w_split_it_adv()
!
!  Revision 1.1.1.1  2001/02/12 15:55:57  gotm
!  initial import into CVS
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: i
   double precision                  :: a,c,saltot
!
!-----------------------------------------------------------------------
!BOC
!  Advection step: 
   if (w_adv_method .ne. 0) then
      call w_split_it_adv(N,dt,h,ho,Y,w,w_adv_discr,surf_flux,bott_flux,flag)
   end if
   if (grid_method .eq. 3) then
      call w_split_it_adv(N,dt,h,ho,Y,w_grid,w_adv_discr,surf_flux,bott_flux,2)
   end if

!SP - the lines with comments below are the same as those without
!  Array of Diffusion/Advection terms + sources 
!  Water column 
!  => [a b c].X=[d] where X=[2, ...,i,i+1,...N-1]
   do i=2,N-1
      c    =2*dt*avh(i)  /(h(i)+h(i+1))/h(i)
      !c    =2*dt*avh(i)  /(h(i)+h(i+1))
     a    =2*dt*avh(i-1)/(h(i)+h(i-1))/h(i)
     !a    =2*dt*avh(i-1)/(h(i)+h(i-1))
      cu(i)=-cnpar*c                                !i+1,n+1
      au(i)=-cnpar*a                                !i-1,n+1
      bu(i)=1-au(i)-cu(i)                           !i  ,n+1
      !bu(i)=h(i)-au(i)-cu(i)                           !i  ,n+1
      du(i)=Y(i)+dt*Qsour(i)               &!i  ,n
            +(1-cnpar)*(a*Y(i-1)-(a+c)*Y(i)+c*Y(i+1))
	!du(i)=h(i)*(Y(i)+dt*Qsour(i))+(1-cnpar)*(a*Y(i-1)-(a+c)*Y(i)+c*Y(i+1))
    end do

!  Surface 
! => [a b /].X=[d] where X=[N-1,N,/]
   if (Bcup.eq.1) then                       !BC Neuman
      a      =2*dt*avh(N-1)/(h(N)+h(N-1))/h(N)
      !a      =2*dt*avh(N-1)/(h(N)+h(N-1))
      au(N)=-cnpar*a
      bu(N)=1-au(N)
      !bu(N)=h(N)-au(N)
      du(N)=Y(N)+dt*(Qsour(N)-Yup/h(N))+(1-cnpar)*a*(Y(N-1)-Y(N))
      !du(N)=Y(N)*h(N)+dt*(h(N)*Qsour(N)-Yup)+(1-cnpar)*a*(Y(N-1)-Y(N))
     
     
   else if (Bcup.eq.2) then                    !BC Dirichlet
      au(N)=0.
      bu(N)=1.
      du(N)=Yup            !seems to work if you include this /avh(N-1)
   end if

!  Bottom  
! => [/ b c].X=[d] where X=[/,1,2]
   if (Bcdw.eq.1) then                                !BC Neuman              
      c    =2*dt*avh(1)/(h(1)+h(2))/h(1)
      !c    =2*dt*avh(1)/(h(1)+h(2))
      cu(1)=-cnpar*c
      bu(1)=1-cu(1) 
      !bu(1)=h(1)-cu(1)
      du(1)=Y(1)+dt*(Qsour(1)+Ydw/h(1))+(1-cnpar)*c*(Y(2)-Y(1))
      !du(1)=Y(1)*h(1)+dt*(h(1)*Qsour(1)+Ydw)+(1-cnpar)*c*(Y(2)-Y(1))
   
   else if (Bcdw.eq.2) then                           !BC Dirichlet
      cu(1)=0.
      bu(1)=1.
      du(1)=Ydw
   end if

!  Implicit internal restoring
   do i=1,N
      if (Taur(i).lt.1.E10) then
         bu(i)=bu(i)+dt/Taur(i)
         du(i)=du(i)+dt/Taur(i)*Yobs(i)
      end if
   end do

!  Implicit vertical mixing
   call tridiagonal(N,1,N,Y)

   return
   end subroutine yevol
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!----------------------------------------------------------------------- 
