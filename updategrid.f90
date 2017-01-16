!-----------------------------------------------------------------------
!BOP
!
! !ROUTINE: The vertical grid \label{sec:updategrid}
!
! !INTERFACE:
   subroutine updategrid(nlev,dt,zeta)
!
! !DESCRIPTION:
!  This subroutine calculates for each time step new layer thicknesses
!  in order to fit them to the changing water depth. 
!  Four different grids can be specified:
!  \begin{enumerate}
!  \item Equidistant grid with possible zooming towards surface and bottom.
!  The number of layers, {\tt nlev}, and the zooming factors,
!  {\tt ddu}=$d_u$ and  {\tt ddl}=$d_l$, 
!  are specified in {\tt gotmmean.inp}.
!  Zooming is applied according to the formula
!  \begin{equation}\label{formula_Antoine}
!    h_k = D\frac{\mbox{tanh}\left( (d_l+d_u)\frac{k}{M}-d_l\right)
!    +\mbox{tanh}(d_l)}{\mbox{tanh}(d_l)+\mbox{tanh}(d_u)}-1
!   \point
!  \end{equation}
!
!  From this formula, the following grids are constructed:
!  \begin{itemize}
!    \item $d_l=d_u=0$ results in equidistant discretisations.
!    \item $d_l>0, d_u=0$ results in zooming near the bottom.
!    \item $d_l=0, d_u>0$ results in zooming near the surface.
!    \item $d_l>0, d_u>0$ results in double zooming nea both, 
!          the surface and the bottom.
!  \end{itemize}
!  
!  \item Sigma--layers. The fraction that every layer occupies is 
!  read--in from file, see {\tt gotmmean.inp}.
!  \item Cartesian layers. The height of every layer is read in from file,
!  see {\tt gotmmean.inp}.
!  This method is not recommended when a varying sea surface is considered.
!  \item Adaptive grid, see {\tt adaptivegrid.F90} described
!  in \sect{sec:adaptivegrid}.
!  \end{enumerate}
!
!  Furthermore, the diagnostic vertical velocity is calculated from
!  \begin{equation}
!  w(z)=\left\{
!  \begin{array}{ll}
!  \displaystyle
!  \frac{\zeta-z}{\zeta-z_w}w_{adv}, & \mbox{for } z\geq z_w \comma \\ \\
!  \displaystyle
!  \frac{z+H}{z_w+H}w_{adv},         & \mbox{for } z<z_w \comma
!  \end{array}
!  \right.
!  \end{equation}
!
! with the observed vertical velocity $w_{adv}$ at height $z_w$, which
! is read in through the {\tt w\_advspec} namelist in {\tt obs.inp}. 
!
! !USES:
   use meanflow,     only: depth0,depth,z,h,ho,ddu,ddl,grid_method
   use meanflow,     only: NN,SS,w_grid,grid_file,w
   use observations, only: zeta_method,w_adv,w_height,w_adv_discr
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: nlev
   double precision, intent(in)                :: dt,zeta
!
! !REVISION HISTORY:
!  Original author(s): Hans Burchard & Karsten Bolding
!  $Log: updategrid.F90,v $
!  Revision 1.9  2003/03/28 09:20:35  kbk
!  added new copyright to files
!
!  Revision 1.8  2003/03/28 08:56:56  kbk
!  removed tabs
!
!  Revision 1.7  2003/03/10 13:43:42  lars
!  double definitions removed - to conform with DEC compiler
!
!  Revision 1.6  2003/03/10 08:50:08  gotm
!  Improved documentation and cleaned up code
!
!  Revision 1.5  2002/02/08 08:33:44  gotm
!  Manuel added support for reading grid distribution from file
!
!  Revision 1.4  2001/11/27 19:51:49  gotm
!  Cleaned
!  Revision 1.3  2001/11/27 15:38:06  gotm
!  Possible to read coordinate distribution from file
!
!  Revision 1.1.1.1  2001/02/12 15:55:57  gotm
!  initial import into CVS
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: i,rc,j,nlayers
   integer, save             :: gridinit  
   double precision                  :: zi(0:nlev)
   double precision                  :: znew,zold
   integer, parameter        :: grid_unit = 101
   double precision, save, dimension(:), allocatable     :: ga
!
!-----------------------------------------------------------------------
!BOC
   if (gridinit .eq. 0) then ! Build up dimensionless grid (0<=ga<=1)  
      allocate(ga(0:nlev),stat=rc)
      if (rc /= 0) STOP 'updategrid: Error allocating (ga)'
      ga(0)=0 
      select case (grid_method)
      case(0) !Equidistant grid with possible zooming to surface and bottom
         write(0,*) '       ', "sigma coordinates (zooming possible)"
         if (ddu .le. 0 .and. ddl .le. 0) then 
            do i=1,nlev 
               ga(i)=ga(i-1)+1/float(nlev)  
            end do  
         else 
            do i=1,nlev ! This zooming routine is from Antoine Garapon, ICCH, DK
               ga(i)=tanh((ddl+ddu)*i/nlev-ddl)+tanh(ddl) 
               ga(i)=ga(i)/(tanh(ddl)+tanh(ddu)) 
            end do 
         end if
         depth = depth0 + Zeta 
         do i=1,nlev
            h(i)=(ga(i)-ga(i-1))*depth
         end do
      case(1) !Sigma, the fraction each layer occupies is specified. 
         write(0,*) '       ', "external specified sigma coordinates"
         open (grid_unit,FILE =grid_file,status='unknown',ERR=100)
         read (grid_unit,*) nlayers
         if (nlayers /= nlev) then
            write(0,*) 'FATAL ERROR: ', "number of layers spefified in file <> # of model layers" 
            stop 'updategrid'
         end if
         depth = 0.0d0
         j = 0
         do i=nlev,1,-1 !The first layer to be read is at the surface
            read(grid_unit,*,ERR=101,END=101) ga(i)
            depth = depth + ga(i)
            j=j+1
         end do

         if (j /= nlayers) then
            write(0,*) 'FATAL ERROR: ', "number of layers read from file <> # of model layers" 
            stop 'updategrid'
         end if
         close (grid_unit)
         if (depth /= 1.) then
            write(0,*) 'FATAL ERROR: ', "sum of all layers in grid_file should be 1."
            stop 'updategrid'
         end if
     case(2) !Cartesian, the layer thickness is read from file
         write(0,*) '       ', "external specified cartesian coordinates"
         open (grid_unit,FILE =grid_file,ERR=100)
! Observations is called after meanflow is initialised, and we don#t have
! zeta_method
!        if (zeta_method /= 0) then
!          stop "You are using Cartesian coordinates with varying surface elevation"
!        end if
         read (grid_unit,*) nlayers
         if(nlayers /= nlev) then
            write(0,*) 'FATAL ERROR: ', "nlev must be equal to the number of layers in: ", &
                   trim(grid_file)
            stop 'updategrid'
         end if  
         depth = 0.0d0
         j=0
         do i=nlev,1,-1 !The first layer read is the surface
            read(grid_unit,*,ERR=101) h(i)
	    depth = depth + h(i)
            j=j+1
         end do
         if (j /= nlayers) then
            write(0,*) 'FATAL ERROR: ', "number of layers read from file <> # of model layers" 
            stop 'updategrid'
         end if
         close (grid_unit)

         if (depth /= depth0) then
            write(0,*) 'FATAL ERROR: ', "sum of all layers should be equal to the total depth",depth0
            stop 'updategrid'
         end if
     case(3) ! Adaptive grid
          ga(0)=-1.
          if (ddu.le.0.and.ddl.le.0) then
             do i=1,nlev
                ga(i)=ga(i-1)+1/float(nlev)
             end do
          else
             do i=1,nlev ! This zooming is from Antoine Garapon, ICCH, DK
                ga(i)=tanh((ddl+ddu)*i/nlev-ddl)+tanh(ddl)
                ga(i)=ga(i)/(tanh(ddl)+tanh(ddu))-1.
             end do
          end if
          depth = depth0 + Zeta
          do i=1,nlev
             h(i)  = (ga(i)-ga(i-1)) * depth
          end do
     case default
         stop "updategrid: No valid grid_method specified"
     end select
     
     gridinit = 1  !  Grid is now initialised ! 
   end if
   
   depth = depth0 + zeta

   select case(grid_method) 
   case (0)   
      do i=1,nlev
         ho(i) = h(i)
         h(i)  = (ga(i)-ga(i-1)) * depth
      end do 
   case (1)
      ho = h
      h = ga *depth
   case (2) 
      ho=h   
   case(3) ! Adaptive grid
      if (w_adv_discr.eq.0) then
         write(0,*) 'You chose to use an adaptive vertical grid, ' 
         write(0,*) 'but set the advection discretisation method to zero.' 
         write(0,*) 'Please set w_adv_discr to a value > zero, for' 
         write(0,*) 'doing so, see namelist w_advspec in obs.inp.' 
         write(0,*) 'Program is aborted now in updategrid.F90.' 
         stop
      end if 
      call adaptivegrid(ga,NN,SS,h,depth,nlev,dt)
      znew=-depth
      zold=-depth
      do i=1,nlev
         ho(i) = h(i)
         h(i)  = (ga(i)-ga(i-1)) * depth
         zold=zold+ho(i)
         znew=znew+h(i)
         w_grid(i)=-(znew-zold)/dt
      end do
    case default
         stop "updategrid: No valid grid_method specified"
   end select   
   
   z(1)=-depth0+0.5*h(1) 
   do i=2,nlev 
      z(i)=z(i-1)+0.5*(h(i-1)+h(i)) 
   end do  

   zi(0)=-depth0
   do i=1,nlev
      zi(i)=zi(i-1)+h(i)
   end do

!  Vertical velocity calculation:

   do i=1,nlev-1
      if (zi(i).gt.w_height) then
         w(i)=(zi(nlev)-zi(i))/(zi(nlev)-w_height)*w_adv
      else
         w(i)=(zi(0)-zi(i))/(zi(0)-w_height)*w_adv
      end if
    end do

    w(0)=0.
    w(nlev)=0.
   
   return

100 write(0,*) 'FATAL ERROR: ', 'Unable to open ',trim(grid_file),' for reading'
   stop 'updategrid'
101 write(0,*) 'FATAL ERROR: ', 'Error reading grid file ',trim(grid_file)
   stop 'updategrid'    

   end subroutine updategrid 
!EOC

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!----------------------------------------------------------------------- 
