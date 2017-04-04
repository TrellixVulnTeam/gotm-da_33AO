!SP
!I have added 3 new output variables, the longwave, latent, and sensible heat 
!fluxes.
!09/04 added skin sst to output variables
!11/04 added cloud to output variables
!03/05 added inovation to output variables
!WT 2016-09-24
! Commented out seviri*, amsri*, tmi*, ostia*, cloud and *error, 
!-----------------------------------------------------------------------
!BOP
!
! !MODULE: ncdfout --- saving the results in NetCDF
!
! !INTERFACE:
   module ncdfout
!
! !DESCRIPTION:!  This module provides routines for saving the GOTM results using
!  NetCDF format. A hack has been provided for saving in a way
!  that can be used by the GrADS graphics software.
!  The {\tt sdfopen()} interface to GrADS
!  does not allow for smaller time units than 1 hour, so if GrADS
!  output is selected the units for time are set to {\tt hours} and
!  not {\tt secs}. In addition, all variables are saved on 
!  the same grid, which is actually a bug to be fixed at a later stage. 
!
! !USES:
   IMPLICIT NONE
   
!
! netcdf version 3 fortran interface:
!

!
! external netcdf data types:
!
      integer nf_byte
      integer nf_int1
      integer nf_char
      integer nf_short
      integer nf_int2
      integer nf_int
      integer nf_float
      integer nf_real
      integer nf_double

      parameter (nf_byte = 1)
      parameter (nf_int1 = nf_byte)
      parameter (nf_char = 2)
      parameter (nf_short = 3)
      parameter (nf_int2 = nf_short)
      parameter (nf_int = 4)
      parameter (nf_float = 5)
      parameter (nf_real = nf_float)
      parameter (nf_double = 6)

!
! default fill values:
!
      integer           nf_fill_byte
      integer           nf_fill_int1
      integer           nf_fill_char
      integer           nf_fill_short
      integer           nf_fill_int2
      integer           nf_fill_int
      real              nf_fill_float
      real              nf_fill_real
      doubleprecision   nf_fill_double

      parameter (nf_fill_byte = -127)
      parameter (nf_fill_int1 = nf_fill_byte)
      parameter (nf_fill_char = 0)
      parameter (nf_fill_short = -32767)
      parameter (nf_fill_int2 = nf_fill_short)
      parameter (nf_fill_int = -2147483647)
      parameter (nf_fill_float = 9.9692099683868690e+36)
      parameter (nf_fill_real = nf_fill_float)
      parameter (nf_fill_double = 9.9692099683868690e+36)

!
! mode flags for opening and creating a netcdf dataset:
!
      integer nf_nowrite
      integer nf_write
      integer nf_clobber
      integer nf_noclobber
      integer nf_fill
      integer nf_nofill
      integer nf_lock
      integer nf_share
      integer nf_sizehint_default
      integer nf_align_chunk

      parameter (nf_nowrite = 0)
      parameter (nf_write = 1)
      parameter (nf_clobber = 0)
      parameter (nf_noclobber = 4)
      parameter (nf_fill = 0)
      parameter (nf_nofill = 256)
      parameter (nf_lock = 1024)
      parameter (nf_share = 2048)
      parameter (nf_sizehint_default = 0)
      parameter (nf_align_chunk = -1)

!
! size argument for defining an unlimited dimension:
!
      integer nf_unlimited
      parameter (nf_unlimited = 0)

!
! global attribute id:
!
      integer nf_global
      parameter (nf_global = 0)

!
! implementation limits:
!
      integer nf_max_dims
      integer nf_max_attrs
      integer nf_max_vars
      integer nf_max_name
      integer nf_max_var_dims

      parameter (nf_max_dims = 100)
      parameter (nf_max_attrs = 2000)
      parameter (nf_max_vars = 2000)
      parameter (nf_max_name = 128)
      parameter (nf_max_var_dims = nf_max_dims)

!
! error codes:
!
      integer nf_noerr
      integer nf_ebadid
      integer nf_eexist
      integer nf_einval
      integer nf_eperm
      integer nf_enotindefine
      integer nf_eindefine
      integer nf_einvalcoords
      integer nf_emaxdims
      integer nf_enameinuse
      integer nf_enotatt
      integer nf_emaxatts
      integer nf_ebadtype
      integer nf_ebaddim
      integer nf_eunlimpos
      integer nf_emaxvars
      integer nf_enotvar
      integer nf_eglobal
      integer nf_enotnc
      integer nf_ests
      integer nf_emaxname
      integer nf_eunlimit
      integer nf_enorecvars
      integer nf_echar
      integer nf_eedge
      integer nf_estride
      integer nf_ebadname
      integer nf_erange
      integer nf_enomem

      parameter (nf_noerr = 0)
      parameter (nf_ebadid = -33)
      parameter (nf_eexist = -35)
      parameter (nf_einval = -36)
      parameter (nf_eperm = -37)
      parameter (nf_enotindefine = -38)
      parameter (nf_eindefine = -39)
      parameter (nf_einvalcoords = -40)
      parameter (nf_emaxdims = -41)
      parameter (nf_enameinuse = -42)
      parameter (nf_enotatt = -43)
      parameter (nf_emaxatts = -44)
      parameter (nf_ebadtype = -45)
      parameter (nf_ebaddim = -46)
      parameter (nf_eunlimpos = -47)
      parameter (nf_emaxvars = -48)
      parameter (nf_enotvar = -49)
      parameter (nf_eglobal = -50)
      parameter (nf_enotnc = -51)
      parameter (nf_ests = -52)
      parameter (nf_emaxname = -53)
      parameter (nf_eunlimit = -54)
      parameter (nf_enorecvars = -55)
      parameter (nf_echar = -56)
      parameter (nf_eedge = -57)
      parameter (nf_estride = -58)
      parameter (nf_ebadname = -59)
      parameter (nf_erange = -60)
      parameter (nf_enomem = -61)

!
! error handling modes:
!
      integer  nf_fatal
      integer nf_verbose

      parameter (nf_fatal = 1)
      parameter (nf_verbose = 2)

!
! miscellaneous routines:
!
      character*80   nf_inq_libvers
      external       nf_inq_libvers

      character*80   nf_strerror
!                         (integer             ncerr)
      external       nf_strerror

      logical        nf_issyserr
!                         (integer             ncerr)
      external       nf_issyserr

!
! control routines:
!
      integer         nf_inq_base_pe
!                         (integer             ncid,
!                          integer             pe)
      external        nf_inq_base_pe

      integer         nf_set_base_pe
!                         (integer             ncid,
!                          integer             pe)
      external        nf_set_base_pe

      integer         nf_create
!                         (character*(*)       path,
!                          integer             cmode,
!                          integer             ncid)
      external        nf_create

      integer         nf__create
!                         (character*(*)       path,
!                          integer             cmode,
!                          integer             initialsz,
!                          integer             chunksizehint,
!                          integer             ncid)
      external        nf__create

      integer         nf__create_mp
!                         (character*(*)       path,
!                          integer             cmode,
!                          integer             initialsz,
!                          integer             basepe,
!                          integer             chunksizehint,
!                          integer             ncid)
      external        nf__create_mp

      integer         nf_open
!                         (character*(*)       path,
!                          integer             mode,
!                          integer             ncid)
      external        nf_open

      integer         nf__open
!                         (character*(*)       path,
!                          integer             mode,
!                          integer             chunksizehint,
!                          integer             ncid)
      external        nf__open

      integer         nf__open_mp
!                         (character*(*)       path,
!                          integer             mode,
!                          integer             basepe,
!                          integer             chunksizehint,
!                          integer             ncid)
      external        nf__open_mp

      integer         nf_set_fill
!                         (integer             ncid,
!                          integer             fillmode,
!                          integer             old_mode)
      external        nf_set_fill

      integer         nf_redef
!                         (integer             ncid)
      external        nf_redef

      integer         nf_enddef
!                         (integer             ncid)
      external        nf_enddef

      integer         nf__enddef
!                         (integer             ncid,
!                          integer             h_minfree,
!                          integer             v_align,
!                          integer             v_minfree,
!                          integer             r_align)
      external        nf__enddef

      integer         nf_sync
!                         (integer             ncid)
      external        nf_sync

      integer         nf_abort
!                         (integer             ncid)
      external        nf_abort

      integer         nf_close
!                         (integer             ncid)
      external        nf_close

      integer         nf_delete
!                         (character*(*)       ncid)
      external        nf_delete

!
! general inquiry routines:
!

      integer         nf_inq
!                         (integer             ncid,
!                          integer             ndims,
!                          integer             nvars,
!                          integer             ngatts,
!                          integer             unlimdimid)
      external        nf_inq

      integer         nf_inq_ndims
!                         (integer             ncid,
!                          integer             ndims)
      external        nf_inq_ndims

      integer         nf_inq_nvars
!                         (integer             ncid,
!                          integer             nvars)
      external        nf_inq_nvars

      integer         nf_inq_natts
!                         (integer             ncid,
!                          integer             ngatts)
      external        nf_inq_natts

      integer         nf_inq_unlimdim
!                         (integer             ncid,
!                          integer             unlimdimid)
      external        nf_inq_unlimdim

!
! dimension routines:
!

      integer         nf_def_dim
!                         (integer             ncid,
!                          character(*)        name,
!                          integer             len,
!                          integer             dimid)
      external        nf_def_dim

      integer         nf_inq_dimid
!                         (integer             ncid,
!                          character(*)        name,
!                          integer             dimid)
      external        nf_inq_dimid

      integer         nf_inq_dim
!                         (integer             ncid,
!                          integer             dimid,
!                          character(*)        name,
!                          integer             len)
      external        nf_inq_dim

      integer         nf_inq_dimname
!                         (integer             ncid,
!                          integer             dimid,
!                          character(*)        name)
      external        nf_inq_dimname

      integer         nf_inq_dimlen
!                         (integer             ncid,
!                          integer             dimid,
!                          integer             len)
      external        nf_inq_dimlen

      integer         nf_rename_dim
!                         (integer             ncid,
!                          integer             dimid,
!                          character(*)        name)
      external        nf_rename_dim

!
! general attribute routines:
!

      integer         nf_inq_att
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len)
      external        nf_inq_att

      integer         nf_inq_attid
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             attnum)
      external        nf_inq_attid

      integer         nf_inq_atttype
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype)
      external        nf_inq_atttype

      integer         nf_inq_attlen
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             len)
      external        nf_inq_attlen

      integer         nf_inq_attname
!                         (integer             ncid,
!                          integer             varid,
!                          integer             attnum,
!                          character(*)        name)
      external        nf_inq_attname

      integer         nf_copy_att
!                         (integer             ncid_in,
!                          integer             varid_in,
!                          character(*)        name,
!                          integer             ncid_out,
!                          integer             varid_out)
      external        nf_copy_att

      integer         nf_rename_att
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        curname,
!                          character(*)        newname)
      external        nf_rename_att

      integer         nf_del_att
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name)
      external        nf_del_att

!
! attribute put/get routines:
!

      integer         nf_put_att_text
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             len,
!                          character(*)        text)
      external        nf_put_att_text

      integer         nf_get_att_text
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          character(*)        text)
      external        nf_get_att_text

      integer         nf_put_att_int1
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          nf_int1_t           i1vals(1))
      external        nf_put_att_int1

      integer         nf_get_att_int1
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          nf_int1_t           i1vals(1))
      external        nf_get_att_int1

      integer         nf_put_att_int2
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          nf_int2_t           i2vals(1))
      external        nf_put_att_int2

      integer         nf_get_att_int2
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          nf_int2_t           i2vals(1))
      external        nf_get_att_int2

      integer         nf_put_att_int
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          integer             ivals(1))
      external        nf_put_att_int

      integer         nf_get_att_int
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             ivals(1))
      external        nf_get_att_int

      integer         nf_put_att_real
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          real                rvals(1))
      external        nf_put_att_real

      integer         nf_get_att_real
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          real                rvals(1))
      external        nf_get_att_real

      integer         nf_put_att_double
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          double              dvals(1))
      external        nf_put_att_double

      integer         nf_get_att_double
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          double              dvals(1))
      external        nf_get_att_double

!
! general variable routines:
!

      integer         nf_def_var
!                         (integer             ncid,
!                          character(*)        name,
!                          integer             datatype,
!                          integer             ndims,
!                          integer             dimids(1),
!                          integer             varid)
      external        nf_def_var

      integer         nf_inq_var
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             datatype,
!                          integer             ndims,
!                          integer             dimids(1),
!                          integer             natts)
      external        nf_inq_var

      integer         nf_inq_varid
!                         (integer             ncid,
!                          character(*)        name,
!                          integer             varid)
      external        nf_inq_varid

      integer         nf_inq_varname
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name)
      external        nf_inq_varname

      integer         nf_inq_vartype
!                         (integer             ncid,
!                          integer             varid,
!                          integer             xtype)
      external        nf_inq_vartype

      integer         nf_inq_varndims
!                         (integer             ncid,
!                          integer             varid,
!                          integer             ndims)
      external        nf_inq_varndims

      integer         nf_inq_vardimid
!                         (integer             ncid,
!                          integer             varid,
!                          integer             dimids(1))
      external        nf_inq_vardimid

      integer         nf_inq_varnatts
!                         (integer             ncid,
!                          integer             varid,
!                          integer             natts)
      external        nf_inq_varnatts

      integer         nf_rename_var
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name)
      external        nf_rename_var

      integer         nf_copy_var
!                         (integer             ncid_in,
!                          integer             varid,
!                          integer             ncid_out)
      external        nf_copy_var

!
! entire variable put/get routines:
!

      integer         nf_put_var_text
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        text)
      external        nf_put_var_text

      integer         nf_get_var_text
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        text)
      external        nf_get_var_text

      integer         nf_put_var_int1
!                         (integer             ncid,
!                          integer             varid,
!                          nf_int1_t           i1vals(1))
      external        nf_put_var_int1

      integer         nf_get_var_int1
!                         (integer             ncid,
!                          integer             varid,
!                          nf_int1_t           i1vals(1))
      external        nf_get_var_int1

      integer         nf_put_var_int2
!                         (integer             ncid,
!                          integer             varid,
!                          nf_int2_t           i2vals(1))
      external        nf_put_var_int2

      integer         nf_get_var_int2
!                         (integer             ncid,
!                          integer             varid,
!                          nf_int2_t           i2vals(1))
      external        nf_get_var_int2

      integer         nf_put_var_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             ivals(1))
      external        nf_put_var_int

      integer         nf_get_var_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             ivals(1))
      external        nf_get_var_int

      integer         nf_put_var_real
!                         (integer             ncid,
!                          integer             varid,
!                          real                rvals(1))
      external        nf_put_var_real

      integer         nf_get_var_real
!                         (integer             ncid,
!                          integer             varid,
!                          real                rvals(1))
      external        nf_get_var_real

      integer         nf_put_var_double
!                         (integer             ncid,
!                          integer             varid,
!                          doubleprecision     dvals(1))
      external        nf_put_var_double

      integer         nf_get_var_double
!                         (integer             ncid,
!                          integer             varid,
!                          doubleprecision     dvals(1))
      external        nf_get_var_double

!
! single variable put/get routines:
!

      integer         nf_put_var1_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          character*1         text)
      external        nf_put_var1_text

      integer         nf_get_var1_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          character*1         text)
      external        nf_get_var1_text

      integer         nf_put_var1_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          nf_int1_t           i1val)
      external        nf_put_var1_int1

      integer         nf_get_var1_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          nf_int1_t           i1val)
      external        nf_get_var1_int1

      integer         nf_put_var1_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          nf_int2_t           i2val)
      external        nf_put_var1_int2

      integer         nf_get_var1_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          nf_int2_t           i2val)
      external        nf_get_var1_int2

      integer         nf_put_var1_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          integer             ival)
      external        nf_put_var1_int

      integer         nf_get_var1_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          integer             ival)
      external        nf_get_var1_int

      integer         nf_put_var1_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          real                rval)
      external        nf_put_var1_real

      integer         nf_get_var1_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          real                rval)
      external        nf_get_var1_real

      integer         nf_put_var1_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          doubleprecision     dval)
      external        nf_put_var1_double

      integer         nf_get_var1_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          doubleprecision     dval)
      external        nf_get_var1_double

!
! variable array put/get routines:
!

      integer         nf_put_vara_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          character(*)        text)
      external        nf_put_vara_text

      integer         nf_get_vara_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          character(*)        text)
      external        nf_get_vara_text

      integer         nf_put_vara_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          nf_int1_t           i1vals(1))
      external        nf_put_vara_int1

      integer         nf_get_vara_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          nf_int1_t           i1vals(1))
      external        nf_get_vara_int1

      integer         nf_put_vara_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          nf_int2_t           i2vals(1))
      external        nf_put_vara_int2

      integer         nf_get_vara_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          nf_int2_t           i2vals(1))
      external        nf_get_vara_int2

      integer         nf_put_vara_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             ivals(1))
      external        nf_put_vara_int

      integer         nf_get_vara_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             ivals(1))
      external        nf_get_vara_int

      integer         nf_put_vara_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          real                rvals(1))
      external        nf_put_vara_real

      integer         nf_get_vara_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          real                rvals(1))
      external        nf_get_vara_real

      integer         nf_put_vara_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          doubleprecision     dvals(1))
      external        nf_put_vara_double

      integer         nf_get_vara_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          doubleprecision     dvals(1))
      external        nf_get_vara_double

!
! strided variable put/get routines:
!

      integer         nf_put_vars_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          character(*)        text)
      external        nf_put_vars_text

      integer         nf_get_vars_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          character(*)        text)
      external        nf_get_vars_text

      integer         nf_put_vars_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          nf_int1_t           i1vals(1))
      external        nf_put_vars_int1

      integer         nf_get_vars_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          nf_int1_t           i1vals(1))
      external        nf_get_vars_int1

      integer         nf_put_vars_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          nf_int2_t           i2vals(1))
      external        nf_put_vars_int2

      integer         nf_get_vars_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          nf_int2_t           i2vals(1))
      external        nf_get_vars_int2

      integer         nf_put_vars_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             ivals(1))
      external        nf_put_vars_int

      integer         nf_get_vars_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             ivals(1))
      external        nf_get_vars_int

      integer         nf_put_vars_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          real                rvals(1))
      external        nf_put_vars_real

      integer         nf_get_vars_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          real                rvals(1))
      external        nf_get_vars_real

      integer         nf_put_vars_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          doubleprecision     dvals(1))
      external        nf_put_vars_double

      integer         nf_get_vars_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          doubleprecision     dvals(1))
      external        nf_get_vars_double

!
! mapped variable put/get routines:
!

      integer         nf_put_varm_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          character(*)        text)
      external        nf_put_varm_text

      integer         nf_get_varm_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          character(*)        text)
      external        nf_get_varm_text

      integer         nf_put_varm_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          nf_int1_t           i1vals(1))
      external        nf_put_varm_int1

      integer         nf_get_varm_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          nf_int1_t           i1vals(1))
      external        nf_get_varm_int1

      integer         nf_put_varm_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          nf_int2_t           i2vals(1))
      external        nf_put_varm_int2

      integer         nf_get_varm_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          nf_int2_t           i2vals(1))
      external        nf_get_varm_int2

      integer         nf_put_varm_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          integer             ivals(1))
      external        nf_put_varm_int

      integer         nf_get_varm_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          integer             ivals(1))
      external        nf_get_varm_int

      integer         nf_put_varm_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          real                rvals(1))
      external        nf_put_varm_real

      integer         nf_get_varm_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          real                rvals(1))
      external        nf_get_varm_real

      integer         nf_put_varm_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          doubleprecision     dvals(1))
      external        nf_put_varm_double

      integer         nf_get_varm_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          doubleprecision     dvals(1))
      external        nf_get_varm_double

!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
! begin netcdf 2.4 backward compatibility:
!

!      
! functions in the fortran interface
!
      integer nccre
      integer ncopn
      integer ncddef
      integer ncdid
      integer ncvdef
      integer ncvid
      integer nctlen
      integer ncsfil

      external nccre
      external ncopn
      external ncddef
      external ncdid
      external ncvdef
      external ncvid
      external nctlen
      external ncsfil


      integer ncrdwr
      integer nccreat
      integer ncexcl
      integer ncindef
      integer ncnsync
      integer nchsync
      integer ncndirty
      integer nchdirty
      integer nclink
      integer ncnowrit
      integer ncwrite
      integer ncclob
      integer ncnoclob
      integer ncglobal
      integer ncfill
      integer ncnofill
      integer maxncop
      integer maxncdim
      integer maxncatt
      integer maxncvar
      integer maxncnam
      integer maxvdims
      integer ncnoerr
      integer ncebadid
      integer ncenfile
      integer nceexist
      integer nceinval
      integer nceperm
      integer ncenotin
      integer nceindef
      integer ncecoord
      integer ncemaxds
      integer ncename
      integer ncenoatt
      integer ncemaxat
      integer ncebadty
      integer ncebadd
      integer ncests
      integer nceunlim
      integer ncemaxvs
      integer ncenotvr
      integer nceglob
      integer ncenotnc
      integer ncfoobar
      integer ncsyserr
      integer ncfatal
      integer ncverbos
      integer ncentool


!
! netcdf data types:
!
      integer ncbyte
      integer ncchar
      integer ncshort
      integer nclong
      integer ncfloat
      integer ncdouble

      parameter(ncbyte = 1)
      parameter(ncchar = 2)
      parameter(ncshort = 3)
      parameter(nclong = 4)
      parameter(ncfloat = 5)
      parameter(ncdouble = 6)

!     
!     masks for the struct nc flag field; passed in as 'mode' arg to
!     nccreate and ncopen.
!     

!     read/write, 0 => readonly 
      parameter(ncrdwr = 1)
!     in create phase, cleared by ncendef 
      parameter(nccreat = 2)
!     on create destroy existing file 
      parameter(ncexcl = 4)
!     in define mode, cleared by ncendef 
      parameter(ncindef = 8)
!     synchronise numrecs on change (x'10')
      parameter(ncnsync = 16)
!     synchronise whole header on change (x'20')
      parameter(nchsync = 32)
!     numrecs has changed (x'40')
      parameter(ncndirty = 64)  
!     header info has changed (x'80')
      parameter(nchdirty = 128)
!     prefill vars on endef and increase of record, the default behavior
      parameter(ncfill = 0)
!     do not fill vars on endef and increase of record (x'100')
      parameter(ncnofill = 256)
!     isa link (x'8000')
      parameter(nclink = 32768)

!     
!     'mode' arguments for nccreate and ncopen
!     
      parameter(ncnowrit = 0)
      parameter(ncwrite = ncrdwr)
      parameter(ncclob = nf_clobber)
      parameter(ncnoclob = nf_noclobber)

!     
!     'size' argument to ncdimdef for an unlimited dimension
!     
      integer ncunlim
      parameter(ncunlim = 0)

!     
!     attribute id to put/get a global attribute
!     
      parameter(ncglobal  = 0)

!     
!     advisory maximums:
!     
      parameter(maxncop = 32)
      parameter(maxncdim = 100)
      parameter(maxncatt = 2000)
      parameter(maxncvar = 2000)
!     not enforced 
      parameter(maxncnam = 128)
      parameter(maxvdims = maxncdim)

!     
!     global netcdf error status variable
!     initialized in error.c
!     

!     no error 
      parameter(ncnoerr = nf_noerr)
!     not a netcdf id 
      parameter(ncebadid = nf_ebadid)
!     too many netcdfs open 
      parameter(ncenfile = -31)   ! nc_syserr
!     netcdf file exists && ncnoclob
      parameter(nceexist = nf_eexist)
!     invalid argument 
      parameter(nceinval = nf_einval)
!     write to read only 
      parameter(nceperm = nf_eperm)
!     operation not allowed in data mode 
      parameter(ncenotin = nf_enotindefine )   
!     operation not allowed in define mode 
      parameter(nceindef = nf_eindefine)   
!     coordinates out of domain 
      parameter(ncecoord = nf_einvalcoords)
!     maxncdims exceeded 
      parameter(ncemaxds = nf_emaxdims)
!     string match to name in use 
      parameter(ncename = nf_enameinuse)   
!     attribute not found 
      parameter(ncenoatt = nf_enotatt)
!     maxncattrs exceeded 
      parameter(ncemaxat = nf_emaxatts)
!     not a netcdf data type 
      parameter(ncebadty = nf_ebadtype)
!     invalid dimension id 
      parameter(ncebadd = nf_ebaddim)
!     ncunlimited in the wrong index 
      parameter(nceunlim = nf_eunlimpos)
!     maxncvars exceeded 
      parameter(ncemaxvs = nf_emaxvars)
!     variable not found 
      parameter(ncenotvr = nf_enotvar)
!     action prohibited on ncglobal varid 
      parameter(nceglob = nf_eglobal)
!     not a netcdf file 
      parameter(ncenotnc = nf_enotnc)
      parameter(ncests = nf_ests)
      parameter (ncentool = nf_emaxname) 
      parameter(ncfoobar = 32)
      parameter(ncsyserr = -31)

!     
!     global options variable. used to determine behavior of error handler.
!     initialized in lerror.c
!     
      parameter(ncfatal = 1)
      parameter(ncverbos = 2)

!
!     default fill values.  these must be the same as in the c interface.
!
      integer filbyte
      integer filchar
      integer filshort
      integer fillong
      real filfloat
      doubleprecision fildoub

      parameter (filbyte = -127)
      parameter (filchar = 0)
      parameter (filshort = -32767)
      parameter (fillong = -2147483647)
      parameter (filfloat = 9.9692099683868690e+36)
      parameter (fildoub = 9.9692099683868690e+36)
!
! !PUBLIC MEMBER FUNCTIONS:
   public init_ncdf, do_ncdf_out, close_ncdf
   public define_mode, new_nc_variable, set_attributes, store_data
!
! !PUBLIC DATA MEMBERS:
   integer, public                     :: ncid
!  dimension ids
   integer                             :: lon_dim,lat_dim,z_dim,z1_dim
   integer                             :: time_dim
   integer, parameter                  :: dim1=1,dim4=4
   integer                             :: dims(dim4)
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  $Log: ncdfout.F90,v $
!  Revision 1.4  2003/03/28 09:20:35  kbk
!  added new copyright to files
!
!  Revision 1.3  2003/03/10 08:53:05  gotm
!  Improved documentation and cleaned up code
!
!  Revision 1.1.1.1  2001/02/12 15:55:58  gotm
!  initial import into CVS
!
!EOP
!
! !PRIVATE DATA MEMBERS
!  dimension lengths
   integer, parameter        :: lon_len=1
   integer, parameter        :: lat_len=1
   integer                   :: depth_len
   integer                   :: time_len=NF_UNLIMITED
!  variable ids
   integer, private          :: lon_id,lat_id,z_id,z1_id,time_id,zeta_id
   !integer, private          :: border_id,swr_error_id,wind_error_id
   ! integer, private          :: seviri_diff_id,seviri_sq_diff_id,seviri_obs_id
   ! integer, private          :: amsre_diff_id,amsre_sq_diff_id,amsre_obs_id
   ! integer, private          :: tmi_diff_id,tmi_sq_diff_id,tmi_obs_id
   ! integer, private          :: ostia_diff_id,ostia_sq_diff_id
   ! integer, private          :: ostia_seviri_diff_id,ostia_amsre_diff_id,ostia_tmi_diff_id
   ! integer, private          :: ostia_seviri_sq_diff_id,ostia_amsre_sq_diff_id,ostia_tmi_sq_diff_id
   integer, private          :: sst_id,sss_id,skint_id,cloud_id
   integer, private          :: x_taus_id,y_taus_id
   integer, private          :: swr_id,heat_id,total_id,lwr_id,sens_id,latent_id
   integer, private          :: int_sw_id,int_hf_id,int_total_id,int_cs_id
   integer, private          :: u_taus_id,u_taub_id
   integer, private          :: h_id
   integer, private          :: u_id,u_obs_id
   integer, private          :: v_id,v_obs_id
   integer, private          :: temp_id,temp_obs_id
   integer, private          :: salt_id,salt_obs_id
   integer, private          :: num_id,nuh_id
   integer, private          :: SS_id,SS_obs_id
   integer, private          :: NN_id,NN_obs_id
   integer, private          :: sigma_t_id,sigma_t_obs_id
   integer, private          :: tke_id,tmls_id
   integer, private          :: tked_id,tked_obs_id
   integer, private          :: prod_shear_id,prod_buoy_id
   integer, private          :: uu_id,vv_id,ww_id,tt_id,chi_id
   integer, private          :: ncdf_time_unit
   integer, private          :: set=1
   integer, private          :: start(4),edges(4)
   logical,save,private      :: GrADS=.false.
!
!-----------------------------------------------------------------------

   contains

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Create the NetCDF file
!
! !INTERFACE:
   subroutine init_ncdf(fn,title,lat,lon,nlev,start_time,time_unit)
   IMPLICIT NONE
!
! !DESCRIPTION:
!  Opens and creates the NetCDF file, and initialises all dimensions and
!  variables for the core GOTM model. 
!
! !INPUT PARAMETERS:
   character(len=*), intent(in)        :: fn,title,start_time
   double precision, intent(in)                :: lat,lon
   integer, intent(in)                 :: nlev,time_unit
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See ncdfout module
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: iret
   character(len=128)        :: ncdf_time_str,history,name
   real(4)                   :: r4
   double precision                  :: miss_val
!
!-------------------------------------------------------------------------
!BOC
   iret = nf_create(fn,NF_CLOBBER,ncid)
   call check_err(iret)

   depth_len=nlev
   ncdf_time_unit = time_unit
   if(time_unit .eq. 2) then
      GrADS = .true.
   end if

!  define dimensions
   iret = nf_def_dim(ncid, 'lon', 1, lon_dim)
   call check_err(iret)
   iret = nf_def_dim(ncid, 'lat', 1, lat_dim)
   call check_err(iret)
   iret = nf_def_dim(ncid, 'z', nlev, z_dim)
   call check_err(iret)
!   if( .not. GrADS ) then
!      iret = nf_def_dim(ncid, 'z1', nlev, z1_dim)
!      call check_err(iret)
!   end if
   iret = nf_def_dim(ncid, 'time', NF_UNLIMITED, time_dim)
   call check_err(iret)

!  define coordinates
   dims(1) = lon_dim
   iret = nf_def_var(ncid,'lon',NF_REAL,1,dims,lon_id)
   call check_err(iret)
   dims(1) = lat_dim
   iret = nf_def_var(ncid,'lat',NF_REAL,1,dims,lat_id)
   call check_err(iret)
   dims(1) = z_dim
   iret = nf_def_var(ncid,'z',NF_REAL,1,dims,z_id)
   call check_err(iret)
 !  if( .not. GrADS ) then
 !     dims(1) = z1_dim
 !     iret = nf_def_var(ncid,'z1',NF_REAL,1,dims,z1_id)
 !     call check_err(iret)
 !  end if
   dims(1) = time_dim
   iret = nf_def_var(ncid,'time',NF_INT,1,dims,time_id)
   call check_err(iret)

!  define variables

!  x,y,t
   dims(1) = lon_dim
   dims(2) = lat_dim
   dims(3) = time_dim
   !iret = nf_def_var(ncid,'zeta',NF_REAL,3,dims, zeta_id)
   !call check_err(iret)
   iret = nf_def_var(ncid,'sst',NF_REAL,3,dims, sst_id)
   call check_err(iret)
   iret = nf_def_var(ncid,'skint',NF_REAL,3,dims, skint_id)
   call check_err(iret)
!   iret = nf_def_var(ncid,'cloud',NF_REAL,3,dims, cloud_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'swr_error',NF_REAL,3,dims, swr_error_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'wind_error',NF_REAL,3,dims, wind_error_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'border',NF_REAL,3,dims, border_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'seviri_diff',NF_REAL,3,dims, seviri_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'seviri_sq_diff',NF_REAL,3,dims, seviri_sq_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'seviri_obs',NF_REAL,3,dims, seviri_obs_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'amsre_diff',NF_REAL,3,dims, amsre_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'amsre_sq_diff',NF_REAL,3,dims, amsre_sq_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'amsre_obs',NF_REAL,3,dims, amsre_obs_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'tmi_diff',NF_REAL,3,dims, tmi_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'tmi_sq_diff',NF_REAL,3,dims, tmi_sq_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'tmi_obs',NF_REAL,3,dims, tmi_obs_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'ostia_diff',NF_REAL,3,dims, ostia_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'ostia_sq_diff',NF_REAL,3,dims, ostia_sq_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'ostia_seviri_diff',NF_REAL,3,dims, ostia_seviri_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'ostia_seviri_sq_diff',NF_REAL,3,dims, ostia_seviri_sq_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'ostia_amsre_diff',NF_REAL,3,dims, ostia_amsre_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'ostia_amsre_sq_diff',NF_REAL,3,dims, ostia_amsre_sq_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'ostia_tmi_diff',NF_REAL,3,dims, ostia_tmi_diff_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'ostia_tmi_sq_diff',NF_REAL,3,dims, ostia_tmi_sq_diff_id)

!   call check_err(iret)
!   iret = nf_def_var(ncid,'sss',NF_REAL,3,dims, sss_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'x-taus',NF_REAL,3,dims, x_taus_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'y-taus',NF_REAL,3,dims, y_taus_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'swr',NF_REAL,3,dims, swr_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'heat',NF_REAL,3,dims, heat_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'total',NF_REAL,3,dims, total_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'lwr',NF_REAL,3,dims, lwr_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'sens',NF_REAL,3,dims, sens_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'latent',NF_REAL,3,dims, latent_id)
!   call check_err(iret)

!   iret = nf_def_var(ncid,'int_sw',NF_REAL,3,dims, int_sw_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'int_hf',NF_REAL,3,dims, int_hf_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'int_total',NF_REAL,3,dims, int_total_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'int_cs',NF_REAL,3,dims, int_cs_id)
!   call check_err(iret)

!   iret = nf_def_var(ncid,'u_taus',NF_REAL,3,dims, u_taus_id)
!   call check_err(iret)
!   iret = nf_def_var(ncid,'u_taub',NF_REAL,3,dims, u_taub_id)
!   call check_err(iret)

!  x,y,z,t
   dims(1) = lon_dim
   dims(2) = lat_dim
   dims(3) = z_dim
   dims(4) = time_dim
 !  iret = nf_def_var(ncid,'h',NF_REAL,4,dims,h_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'u',NF_REAL,4,dims,u_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'u_obs',NF_REAL,4,dims,u_obs_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'v',NF_REAL,4,dims,v_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'v_obs',NF_REAL,4,dims,v_obs_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'salt',NF_REAL,4,dims,salt_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'salt_obs',NF_REAL,4,dims,salt_obs_id)
 !  call check_err(iret)
   iret = nf_def_var(ncid,'temp',NF_REAL,4,dims,temp_id)
   call check_err(iret)
 !  iret = nf_def_var(ncid,'temp_obs',NF_REAL,4,dims,temp_obs_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'SS',NF_REAL,4,dims,SS_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'SS_obs',NF_REAL,4,dims,SS_obs_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'NN',NF_REAL,4,dims,NN_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'NN_obs',NF_REAL,4,dims,NN_obs_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'sigma_t',NF_REAL,4,dims,sigma_t_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'sigma_t_obs',NF_REAL,4,dims,sigma_t_obs_id)
 !  call check_err(iret)
 !  if( .not. GrADS ) then
 !     dims(3) = z1_dim
 !  end if
 !  iret = nf_def_var(ncid,'num',NF_REAL,4,dims,num_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'nuh',NF_REAL,4,dims,nuh_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'tke',NF_REAL,4,dims,tke_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'tmls',NF_REAL,4,dims,tmls_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'tked',NF_REAL,4,dims,tked_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'tked_obs',NF_REAL,4,dims,tked_obs_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'prod_shear',NF_REAL,4,dims,prod_shear_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'prod_buoy',NF_REAL,4,dims,prod_buoy_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'uu',NF_REAL,4,dims,uu_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'vv',NF_REAL,4,dims,vv_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'ww',NF_REAL,4,dims,ww_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'tt',NF_REAL,4,dims,tt_id)
 !  call check_err(iret)
 !  iret = nf_def_var(ncid,'chi',NF_REAL,4,dims,chi_id)
 !  call check_err(iret)

!  assign attributes

!  coordinates
   iret = set_attributes(ncid,lon_id,units='degrees_east')
   iret = set_attributes(ncid,lat_id,units='degrees_north')
   iret = set_attributes(ncid,z_id,units='meters')
!   iret = set_attributes(ncid,z1_id,units='meters')
!   iret = set_attributes(ncid,swr_error_id,units='no units')
!   iret = set_attributes(ncid,wind_error_id,units='no units')
!   iret = set_attributes(ncid,border_id,units='no units')


   select case (ncdf_time_unit)
      case(0)                           ! seconds
         write(ncdf_time_str,100) 'secs',trim(start_time)
      case(1)                           ! minutes
         write(ncdf_time_str,100) 'mins',trim(start_time)
      case(2)                           ! hours
         write(ncdf_time_str,100) 'hours',trim(start_time)
      case default
         write(ncdf_time_str,100) 'secs',trim(start_time)
   end select
100 format(A,' since ',A)
   iret = set_attributes(ncid,time_id,units=trim(ncdf_time_str))

!  x,y,t
!   iret = set_attributes(ncid,zeta_id,units='m',long_name='sea surface elevation')
   iret = set_attributes(ncid,sst_id,units='celsius',long_name='sea surface temperature')
   iret = set_attributes(ncid,skint_id,units='celsius',long_name='skin sea surface temperature')
!   iret = set_attributes(ncid,seviri_diff_id,units='celsius',long_name='sum of seviri differences')
!   iret = set_attributes(ncid,seviri_sq_diff_id,units='celsius',long_name='sum of seviri squared differences')
!   iret = set_attributes(ncid,seviri_obs_id,units='dimensionless',long_name='total number of seviri observations')
!   iret = set_attributes(ncid,amsre_diff_id,units='celsius',long_name='sum of amsre differences')
!   iret = set_attributes(ncid,amsre_sq_diff_id,units='celsius',long_name='sum of amsre squared differences')
!   iret = set_attributes(ncid,amsre_obs_id,units='dimensionless',long_name='total number of amsre observations')
!   iret = set_attributes(ncid,tmi_diff_id,units='celsius',long_name='sum of tmi differences')
!   iret = set_attributes(ncid,tmi_sq_diff_id,units='celsius',long_name='sum of tmi squared differences')
!   iret = set_attributes(ncid,tmi_obs_id,units='dimensionless',long_name='total number of tmi observations')
!   iret = set_attributes(ncid,ostia_diff_id,units='celsius',long_name='sum of ostia differences')
!   iret = set_attributes(ncid,ostia_sq_diff_id,units='celsius',long_name='sum of ostia squared differences')
!   iret = set_attributes(ncid,ostia_seviri_diff_id,units='celsius',long_name='sum of ostia-seviri differences')
!   iret = set_attributes(ncid,ostia_seviri_sq_diff_id,units='celsius',long_name='sum of ostia-seviri squared differences')
!   iret = set_attributes(ncid,ostia_amsre_diff_id,units='celsius',long_name='sum of ostia-amsre differences')
!   iret = set_attributes(ncid,ostia_amsre_sq_diff_id,units='celsius',long_name='sum of ostia-amsre squared differences')
!   iret = set_attributes(ncid,ostia_tmi_diff_id,units='celsius',long_name='sum of ostia-tmi differences')
!   iret = set_attributes(ncid,ostia_tmi_sq_diff_id,units='celsius',long_name='sum of ostia-tmi squared differences')
!   iret = set_attributes(ncid,cloud_id,units='tenths',long_name='total fractional cloud cover')

!   iret = set_attributes(ncid,sss_id,units='psu',long_name='sea surface salinity')
!   iret = set_attributes(ncid,x_taus_id,units='N/m2',long_name='x-wind stress')
!   iret = set_attributes(ncid,y_taus_id,units='N/m2',long_name='y-wind stress')
!   iret = set_attributes(ncid,swr_id,units='W/m2',long_name='short wave radiation')
!   iret = set_attributes(ncid,heat_id,units='W/m2',long_name='surface heat flux')
!   iret = set_attributes(ncid,total_id,units='W/m2',long_name='total surface heat exchange')
!   iret = set_attributes(ncid,lwr_id,units='W/m2',long_name='long wave radiation')
!   iret = set_attributes(ncid,sens_id,units='W/m2',long_name='sensible heat flux')
!   iret = set_attributes(ncid,latent_id,units='W/m2',long_name='latent heat flux')
!   iret = set_attributes(ncid,int_sw_id,units='J/m2',long_name='integrated short wave radiation')
!   iret = set_attributes(ncid,int_hf_id,units='J/m2',long_name='integrated surface heat flux')
!   iret = set_attributes(ncid,int_total_id,units='J/m2',long_name='integrated total surface heat exchange')
!   iret = set_attributes(ncid,int_cs_id,units='J/m2',long_name='integrated clear sky short wave radiation')
!   iret = set_attributes(ncid,u_taus_id,units='m/s',long_name='surface friction velocity')
!   iret = set_attributes(ncid,u_taub_id,units='m/s',long_name='bottom friction velocity')

!  x,y,z,t
 !  iret = set_attributes(ncid,h_id,units='meters',long_name='layer thickness')
 !  iret = set_attributes(ncid,u_id,units='m/s',long_name='x-velocity')
 !  iret = set_attributes(ncid,u_obs_id,units='m/s',long_name='obs. x-velocity')
 !  iret = set_attributes(ncid,v_id,units='m/s',long_name='y-velocity')
 !  iret = set_attributes(ncid,v_obs_id,units='m/s',long_name='obs. y-velocity')
 !  iret = set_attributes(ncid,salt_id,units='ppt',long_name='salinity')
 !  iret = set_attributes(ncid,salt_obs_id,units='ppt',long_name='obs. salinity')
   iret = set_attributes(ncid,temp_id,units='celsius',long_name='temperature')
  ! iret = set_attributes(ncid,temp_obs_id,units='celcius',long_name='obs. temperature')
  ! iret = set_attributes(ncid,SS_id,units='s-1',long_name='shear frequency')
  ! iret = set_attributes(ncid,NN_id,units='s-1',long_name='buoyancy frequency')
  ! iret = set_attributes(ncid,sigma_t_id,units='s-1',long_name='sigma_t')
  ! iret = set_attributes(ncid,SS_obs_id,units='s-1',long_name='observed shear frequency')
  ! iret = set_attributes(ncid,NN_obs_id,units='s-1',long_name='observed buoyancy frequency')
  ! iret = set_attributes(ncid,sigma_t_obs_id,units='s-1',long_name='observed sigma_t')

!  x,y,z1,t
!   iret = set_attributes(ncid,num_id,units='m2/s',long_name='viscosity')
!   iret = set_attributes(ncid,nuh_id,units='m2/s',long_name='diffusivity')
!   iret = set_attributes(ncid,tke_id,units='m2/s2',long_name='turbulent kinetic energy')
!   iret = set_attributes(ncid,tmls_id,units='meters',long_name='turbulent macro length scale')
!   iret = set_attributes(ncid,tked_id,units='m2/s3',long_name='turbulent kinetic energy dissipation')
!   iret = set_attributes(ncid,tked_obs_id,units='m2/s3',long_name='obs. dissipation')
!   iret = set_attributes(ncid,prod_shear_id,units='m2/s3',long_name='shear production')
!   iret = set_attributes(ncid,prod_buoy_id,units='m2/s3',long_name='buoyancy production')

!   iret = set_attributes(ncid,uu_id,units='(m/s)2',long_name='Reynolds stress (u)')
!   iret = set_attributes(ncid,vv_id,units='(m/s)2',long_name='Reynolds stress (v)')
!   iret = set_attributes(ncid,ww_id,units='(m/s)2',long_name='Reynolds stress (w)')
!   iret = set_attributes(ncid,tt_id,units='K2',long_name='temperature variance')
!   iret = set_attributes(ncid,chi_id,units='K2/s',long_name='temperature dissipation')

!  global attributes
   iret = nf_put_att_text(ncid,NF_GLOBAL,'Title',LEN_TRIM(title),title)
   history = 'Created by GOTM v. '//"3.0.0"
   iret = nf_put_att_text(ncid,NF_GLOBAL,'history',LEN_TRIM(history),history)
   iret = nf_put_att_text(ncid,NF_GLOBAL,'Conventions',6,'COARDS')
   call check_err(iret)

!  leave define mode
   iret = nf_enddef(ncid)
   call check_err(iret)

!  save latitude and logitude
   iret = store_data(ncid,lon_id,0,1,scalar=lon)
   iret = store_data(ncid,lat_id,0,1,scalar=lat)

   iret = nf_sync(ncid)
   call check_err(iret)

   return
   end subroutine init_ncdf
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Save model results to file
!
! !INTERFACE:
   subroutine do_ncdf_out(nlev,secs)
!
! !DESCRIPTION:
!  Write the GOTM core variables to the NetCDF file.
!
! !USES:
   use airsea,       only: tx,ty,I_0,heat,sst,sss,int_sw,int_hf,int_total,int_cs,qb,qh,qe,skint,cloud,swr_error,wind_error,border
   use meanflow,     only: depth0,u_taub,u_taus,rho_0,gravity
   use meanflow,     only: h,u,v,z,S,T,buoy,SS,NN,P,B
   ! use airsea, only                : seviri_diff,seviri_sq_diff,seviri_obs
   ! use airsea, only                : amsre_diff,amsre_sq_diff,amsre_obs
   ! use airsea, only                : tmi_diff,tmi_sq_diff,tmi_obs
   ! use airsea, only                : ostia_diff,ostia_sq_diff
   ! use airsea, only                : ostia_seviri_diff,ostia_amsre_diff
   ! use airsea, only                : ostia_tmi_diff,ostia_seviri_sq_diff
   ! use airsea, only                : ostia_amsre_sq_diff,ostia_tmi_sq_diff
   use turbulence,   only: num,nuh,tke,eps,L,uu,vv,ww,tt,chi
   use observations, only: zeta,uprof,vprof,tprof,sprof,epsprof
   use eqstate,      only: eqstate1

   IMPLICIT NONE

!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: nlev
   integer, intent(in)                 :: secs
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See ncdfout module
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: iret,i
   integer                   :: time
   double precision                  :: dum(0:nlev)
   real(4)                   :: buoyp,buoym,dz
   double precision                  :: zz
   logical, save             :: first = .true.
!
!-------------------------------------------------------------------------
!BOC
   if ( first ) then
      !iret = store_data(ncid,z_id,1,nlev,array=-z(nlev+1:1:-1)) 
      iret = store_data(ncid,z_id,1,nlev,array=z)
      if( .not. GrADS ) then
         dum(1) = -depth0 + h(1)
         do i=2,nlev
            dum(i)=dum(i-1)+h(i)
         end do
        ! iret = store_data(ncid,z1_id,1,nlev,array=dum)
      end if
      first = .false.
   end if

!  Storing the time - both the coordinate and later a time string.
   select case (ncdf_time_unit)
      case(0)                           ! seconds
         time = secs
      case(1)                           ! minutes
         time = secs/60
      case(2)                           ! hours
         time = secs/3600
      case default
         time = secs
   end select
   iret = store_data(ncid,time_id,2,1,iscalar=time)

!  Time varying data : x,y,t 
!   iret = store_data(ncid,zeta_id,4,1,scalar=zeta)
   iret = store_data(ncid,sst_id,4,1,scalar=sst)
   iret = store_data(ncid,skint_id,4,1,scalar=skint)
   !iret = store_data(ncid,swr_error_id,4,1,scalar=swr_error)
   !iret = store_data(ncid,wind_error_id,4,1,scalar=wind_error)
   !iret = store_data(ncid,border_id,4,1,scalar=border)
   !iret = store_data(ncid,seviri_diff_id,4,1,scalar=seviri_diff)
   !iret = store_data(ncid,seviri_sq_diff_id,4,1,scalar=seviri_sq_diff)
   !iret = store_data(ncid,seviri_obs_id,4,1,scalar=seviri_obs)
   !iret = store_data(ncid,amsre_diff_id,4,1,scalar=amsre_diff)
   !iret = store_data(ncid,amsre_sq_diff_id,4,1,scalar=amsre_sq_diff)
   !iret = store_data(ncid,amsre_obs_id,4,1,scalar=amsre_obs)
   !iret = store_data(ncid,tmi_diff_id,4,1,scalar=tmi_diff)
   !iret = store_data(ncid,tmi_sq_diff_id,4,1,scalar=tmi_sq_diff)
   !iret = store_data(ncid,tmi_obs_id,4,1,scalar=tmi_obs)
   !iret = store_data(ncid,ostia_diff_id,4,1,scalar=ostia_diff)
   !iret = store_data(ncid,ostia_sq_diff_id,4,1,scalar=ostia_sq_diff)
   !iret = store_data(ncid,ostia_tmi_diff_id,4,1,scalar=ostia_tmi_diff)
   !iret = store_data(ncid,ostia_tmi_sq_diff_id,4,1,scalar=ostia_tmi_sq_diff)
   !iret = store_data(ncid,ostia_amsre_diff_id,4,1,scalar=ostia_amsre_diff)
   !iret = store_data(ncid,ostia_amsre_sq_diff_id,4,1,scalar=ostia_amsre_sq_diff)
   !iret = store_data(ncid,ostia_seviri_diff_id,4,1,scalar=ostia_seviri_diff)
   !iret = store_data(ncid,ostia_seviri_sq_diff_id,4,1,scalar=ostia_seviri_sq_diff)
   !iret = store_data(ncid,cloud_id,4,1,scalar=cloud)
!   iret = store_data(ncid,sss_id,4,1,scalar=sss)
!   iret = store_data(ncid,x_taus_id,4,1,scalar=tx)
!   iret = store_data(ncid,y_taus_id,4,1,scalar=ty)
!   iret = store_data(ncid,swr_id,4,1,scalar=I_0)
!   iret = store_data(ncid,heat_id,4,1,scalar=heat)
!   iret = store_data(ncid,total_id,4,1,scalar=heat+I_0)
!   iret = store_data(ncid,lwr_id,4,1,scalar=-qb)
!   iret = store_data(ncid,sens_id,4,1,scalar=-qh)
!   iret = store_data(ncid,latent_id,4,1,scalar=-qe)
!   iret = store_data(ncid,int_sw_id,4,1,scalar=int_sw)
!   iret = store_data(ncid,int_hf_id,4,1,scalar=int_hf)
!   iret = store_data(ncid,int_total_id,4,1,scalar=int_total)
!   iret = store_data(ncid,int_cs_id,4,1,scalar=int_cs)
!   iret = store_data(ncid,u_taub_id,4,1,scalar=u_taub)
!   iret = store_data(ncid,u_taus_id,4,1,scalar=u_taus)

!  Time varying profile data : x,y,z,t
 !  iret = store_data(ncid,h_id,5,nlev,array=h)
 !  iret = store_data(ncid,u_id,5,nlev,array=u)
 !  iret = store_data(ncid,u_obs_id,5,nlev,array=uprof)
 !  iret = store_data(ncid,v_id,5,nlev,array=v)
 !  iret = store_data(ncid,v_obs_id,5,nlev,array=vprof)
 !  iret = store_data(ncid,salt_id,5,nlev,array=S)
 !  iret = store_data(ncid,salt_obs_id,5,nlev,array=sprof)
   iret = store_data(ncid,temp_id,5,nlev,array=T)
 !  iret = store_data(ncid,temp_obs_id,5,nlev,array=tprof)
 !  iret = store_data(ncid,SS_id,5,nlev,array=SS)
 !  iret = store_data(ncid,NN_id,5,nlev,array=NN)

 !  dum(1:nlev)=-buoy(1:nlev)*rho_0/gravity+rho_0-1000.
 !  iret = store_data(ncid,sigma_t_id,5,nlev,array=dum)

 !  do i=1,nlev-1
 !    dum(i)=((uprof(i+1)-uprof(i))/(0.5*(h(i+1)+h(i))))**2 +  &
 !           ((vprof(i+1)-vprof(i))/(0.5*(h(i+1)+h(i))))**2
 !  end do
 !  dum(nlev)=dum(nlev-1)
 !  iret = store_data(ncid,SS_obs_id,5,nlev,array=dum)

 !  zz = 0.0d0
 !  do i=nlev-1,1,-1
 !     zz=zz+h(i+1)
 !     dz=0.5*(h(i)+h(i+1))
 !     buoyp=eqstate1(sprof(i+1),tprof(i+1),zz/10.,gravity,rho_0)
 !     buoym=eqstate1(sprof(i  ),tprof(i  ),zz/10.,gravity,rho_0)
 !     dum(i)=(buoyp-buoym)/dz
 !  end do
 !  iret = store_data(ncid,NN_obs_id,5,nlev,array=dum)

 !  dum(1:nlev)=-buoy(1:nlev)*rho_0/gravity+rho_0-1000.
 !  zz = 0.0d0
 !  do i=nlev,1,-1
 !     zz=zz+0.5*h(i)
 !     dum(i)=eqstate1(sprof(i),tprof(i),zz/10.,gravity,rho_0)
 !     zz=zz+0.5*h(i)
 !  end do
 !  dum(1:nlev)=-dum(1:nlev)*rho_0/gravity+rho_0-1000.
 !  iret = store_data(ncid,sigma_t_obs_id,5,nlev,array=dum)

!  Time varying profile data : x,y,z1,t
!   iret = store_data(ncid,num_id,5,nlev,array=num)
!   iret = store_data(ncid,nuh_id,5,nlev,array=nuh)
!   iret = store_data(ncid,tke_id,5,nlev,array=tke)
!   iret = store_data(ncid,tked_id,5,nlev,array=eps)
!   iret = store_data(ncid,tmls_id,5,nlev,array=L)
!   iret = store_data(ncid,tked_obs_id,5,nlev,array=epsprof)
!   iret = store_data(ncid,prod_shear_id,5,nlev,array=P)
!   iret = store_data(ncid,prod_buoy_id,5,nlev,array=B)
!   iret = store_data(ncid,uu_id,5,nlev,array=uu)
!   iret = store_data(ncid,vv_id,5,nlev,array=vv)
!   iret = store_data(ncid,ww_id,5,nlev,array=ww)
!   iret = store_data(ncid,tt_id,5,nlev,array=tt)
!   iret = store_data(ncid,chi_id,5,nlev,array=chi)

   set = set + 1

   iret = nf_sync(ncid)
   call check_err(iret)

   return
   end subroutine do_ncdf_out
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Close files used for saving model results
!
! !INTERFACE:
   subroutine close_ncdf()
   IMPLICIT NONE
!
! !DESCRIPTION:
!  Closes the NetCDF file.
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See ncdfout module
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: iret
!
!-------------------------------------------------------------------------
!BOC
   write(0,*) '   ', 'Output has been written in NetCDF'

   iret = nf_close(ncid)
   call check_err(iret)

   return
   end subroutine close_ncdf
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Begin or end define mode
!
! !INTERFACE:
   integer function define_mode(ncid,action)
!
! !DESCRIPTION:
!  Depending on the value of the argument {\tt action},
!  this routine put NetCDF in the `define' mode or not.
!
! !USES:
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)       :: ncid
   logical, intent(in)       :: action
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See ncdfout module
!
!EOP
!
! !LOCAL VARIABLES:
   integer	:: iret
!
!-----------------------------------------------------------------------
!BOC
   if(action) then
      iret = nf_redef(ncid)
!kbk      call check_err(iret)
   else
      iret = nf_enddef(ncid)
!kbk      call check_err(iret)
   end if
   define_mode = 0
   return
   end function define_mode
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Define a new NetCDF variable
!
! !INTERFACE:
   integer function new_nc_variable(ncid,name,data_type,n,dims,id)
!
! !DESCRIPTION:
!  This routine is used to define a new variable to store in a NetCDF file.
!
! !USES:
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: ncid
   character(len=*), intent(in)        :: name
   integer, intent(in)                 :: data_type,n
   integer, intent(in)                 :: dims(:)
!
! !OUTPUT PARAMETERS:
   integer, intent(out)                :: id
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See ncdfout module
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: iret
!
!-----------------------------------------------------------------------
!BOC
   iret = nf_def_var(ncid,name,data_type,n,dims,id)
   call check_err(iret)
   new_nc_variable = iret
   return
   end function new_nc_variable
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Set attributes for a NetCDF variable.
!
! !INTERFACE:
   integer function set_attributes(ncid,id,                         &
                                   units,long_name,                 &
                                   valid_min,valid_max,valid_range, &
                                   scale_factor,add_offset,         &
                                   FillValue,missing_value,         &
                                   C_format,FORTRAN_format)
!
! !DESCRIPTION:
!  This routine is used to set a number of attributes for 
!  variables. The routine makes heavy use of the {\tt optional} keyword. 
!  The list of recognized keywords is very easy to extend. We have 
!  included a sub-set of the COARDS conventions. 
!
! !USES:
!  IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: ncid,id
   character(len=*), optional          :: units,long_name
   double precision, optional                  :: valid_min,valid_max
   double precision, optional                  :: valid_range(2)
   double precision, optional                  :: scale_factor,add_offset
   double precision, optional                  :: FillValue,missing_value
   character(len=*), optional          :: C_format,FORTRAN_format
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See ncdfout module
!
! !LOCAL VARIABLES:
   integer                   :: len,iret
   real(4)                   :: vals(2)
!
!EOP
!-----------------------------------------------------------------------
!BOC
   if(present(units)) then
      len = len_trim(units)
      iret = nf_put_att_text(ncid,id,'units',len,units)
   end if

   if(present(long_name)) then
      len = len_trim(long_name)
      iret = nf_put_att_text(ncid,id,'long_name',len,long_name)
   end if

   if(present(C_format)) then
      len = len_trim(C_format)
      iret = nf_put_att_text(ncid,id,'C_format',len,C_format)
   end if

   if(present(FORTRAN_format)) then
      len = len_trim(FORTRAN_format)
      iret = nf_put_att_text(ncid,id,'FORTRAN_format',len,FORTRAN_format)
   end if

   if(present(valid_min)) then
      vals(1) = valid_min
      iret = nf_put_att_real(ncid,id,'valid_min',NF_FLOAT,1,vals)
   end if

   if(present(valid_max)) then
      vals(1) = valid_max
      iret = nf_put_att_real(ncid,id,'valid_max',NF_FLOAT,1,vals)
   end if

   if(present(valid_range)) then
      vals(1) = valid_range(1)
      vals(2) = valid_range(2)
      iret = nf_put_att_real(ncid,id,'valid_range',NF_FLOAT,2,vals)
   end if

   if(present(scale_factor)) then
      vals(1) = scale_factor
      iret = nf_put_att_real(ncid,id,'scale_factor',NF_FLOAT,1,vals)
   end if

   if(present(add_offset)) then
      vals(1) = add_offset
      iret = nf_put_att_real(ncid,id,'add_offset',NF_FLOAT,1,vals)
   end if

   if(present(FillValue)) then
      vals(1) = FillValue
      iret = nf_put_att_real(ncid,id,'_FillValue',NF_FLOAT,1,vals)
   end if

   if(present(missing_value)) then
      vals(1) = missing_value
      iret = nf_put_att_real(ncid,id,'missing_value',NF_FLOAT,1,vals)
   end if

   set_attributes = 0
   return
   end function set_attributes
!EOC

!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Store values in a NetCDF file
!
! !INTERFACE:
   integer function store_data(ncid,id,var_shape,nlev, &
                               iscalar,iarray,scalar,array)
!
! !DESCRIPTION:
!  This routine is used to store a  variable in the NetCDF file.
!  The subroutine uses {\tt optional} parameters to find out which data
!  type to save.
!
! !USES:
   IMPLICIT NONE
!
! !INPUT PARAMETERS:
   integer, intent(in)                 :: ncid,id,var_shape,nlev
   integer, optional                   :: iscalar
   integer, optional                   :: iarray(0:nlev)
   double precision, optional                  :: scalar
   double precision, optional                  :: array(0:nlev)
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!  See ncdfout module
!
!EOP
!
! !LOCAL VARIABLES:
   integer                   :: iret,n=0
   integer                   :: idum(1:nlev)
   real(4)                   :: r4,dum(1:nlev)
!
!-----------------------------------------------------------------------
!BOC
   if (.not. present(iscalar) .and. .not. present(iarray) .and. &
       .not. present(scalar)  .and. .not. present(array) ) then
      write(0,*) 'FATAL ERROR: ', 'At least one optional argument has to be passed to - store_data()'
      stop 'store_data'
   end if
   n = 0
   if(present(iscalar)) n = n+1
   if(present(iarray))  n = n+1
   if(present(scalar))  n = n+1
   if(present(array))   n = n+1
   if(n .ne. 1) then
      write(0,*) 'FATAL ERROR: ', 'Only one optional argument must be passed to - store_data()'
      stop 'store_data'
   end if

   if (present(iscalar)) then
      select case (var_shape)
         case(0)
            iret = nf_put_var_int(ncid,id,iscalar)
         case(2)
            start(1) = set; edges(1) = 1
            idum(1)=iscalar
            iret = nf_put_vara_int(ncid,id,start,edges,idum)
         case default
            write(0,*) 'FATAL ERROR: ', 'A non valid - var_shape - has been passed in store_data()'
            stop 'store_data'
      end select
   else if (present(scalar)) then
      select case (var_shape)
         case(0)
            r4 = scalar
            iret = nf_put_var_real(ncid,id,r4)
         case(2)
            start(1) = set; edges(1) = 1
            dum(1)=scalar
            iret = nf_put_vara_real(ncid,id,start,edges,dum)
         case(4)
            start(1) = 1;   edges(1) = lon_len
            start(2) = 1;   edges(2) = lat_len
            start(3) = set; edges(3) = 1
            dum(1)=scalar
            iret = nf_put_vara_real(ncid,id,start,edges,dum)
         case default
            write(0,*) 'FATAL ERROR: ', 'A non valid - var_shape - has been passed in store_data()'
            stop 'store_data'
      end select
   else if (present(array)) then
      select case (var_shape)
         case(1)
            start(1) = 1;   edges(1) = depth_len
         case(5)
            start(1) = 1;   edges(1) = lon_len
            start(2) = 1;   edges(2) = lat_len
            start(3) = 1;   edges(3) = depth_len
            start(4) = set; edges(4) = 1
         case default
            write(0,*) 'FATAL ERROR: ', 'A non valid - var_shape - has been passed in store_data()'
            stop 'store_data'
      end select
      dum(1:nlev)=array(1:nlev)
      iret = nf_put_vara_real(ncid,id,start,edges,dum)
   else
   end if
   call check_err(iret)
   store_data = iret
   return
   end function store_data
!EOC

!-----------------------------------------------------------------------

   end module ncdfout

!-----------------------------------------------------------------------

   subroutine check_err(iret)
   integer iret
   
!
! netcdf version 3 fortran interface:
!

!
! external netcdf data types:
!
      integer nf_byte
      integer nf_int1
      integer nf_char
      integer nf_short
      integer nf_int2
      integer nf_int
      integer nf_float
      integer nf_real
      integer nf_double

      parameter (nf_byte = 1)
      parameter (nf_int1 = nf_byte)
      parameter (nf_char = 2)
      parameter (nf_short = 3)
      parameter (nf_int2 = nf_short)
      parameter (nf_int = 4)
      parameter (nf_float = 5)
      parameter (nf_real = nf_float)
      parameter (nf_double = 6)

!
! default fill values:
!
      integer           nf_fill_byte
      integer           nf_fill_int1
      integer           nf_fill_char
      integer           nf_fill_short
      integer           nf_fill_int2
      integer           nf_fill_int
      real              nf_fill_float
      real              nf_fill_real
      doubleprecision   nf_fill_double

      parameter (nf_fill_byte = -127)
      parameter (nf_fill_int1 = nf_fill_byte)
      parameter (nf_fill_char = 0)
      parameter (nf_fill_short = -32767)
      parameter (nf_fill_int2 = nf_fill_short)
      parameter (nf_fill_int = -2147483647)
      parameter (nf_fill_float = 9.9692099683868690e+36)
      parameter (nf_fill_real = nf_fill_float)
      parameter (nf_fill_double = 9.9692099683868690e+36)

!
! mode flags for opening and creating a netcdf dataset:
!
      integer nf_nowrite
      integer nf_write
      integer nf_clobber
      integer nf_noclobber
      integer nf_fill
      integer nf_nofill
      integer nf_lock
      integer nf_share
      integer nf_sizehint_default
      integer nf_align_chunk

      parameter (nf_nowrite = 0)
      parameter (nf_write = 1)
      parameter (nf_clobber = 0)
      parameter (nf_noclobber = 4)
      parameter (nf_fill = 0)
      parameter (nf_nofill = 256)
      parameter (nf_lock = 1024)
      parameter (nf_share = 2048)
      parameter (nf_sizehint_default = 0)
      parameter (nf_align_chunk = -1)

!
! size argument for defining an unlimited dimension:
!
      integer nf_unlimited
      parameter (nf_unlimited = 0)

!
! global attribute id:
!
      integer nf_global
      parameter (nf_global = 0)

!
! implementation limits:
!
      integer nf_max_dims
      integer nf_max_attrs
      integer nf_max_vars
      integer nf_max_name
      integer nf_max_var_dims

      parameter (nf_max_dims = 100)
      parameter (nf_max_attrs = 2000)
      parameter (nf_max_vars = 2000)
      parameter (nf_max_name = 128)
      parameter (nf_max_var_dims = nf_max_dims)

!
! error codes:
!
      integer nf_noerr
      integer nf_ebadid
      integer nf_eexist
      integer nf_einval
      integer nf_eperm
      integer nf_enotindefine
      integer nf_eindefine
      integer nf_einvalcoords
      integer nf_emaxdims
      integer nf_enameinuse
      integer nf_enotatt
      integer nf_emaxatts
      integer nf_ebadtype
      integer nf_ebaddim
      integer nf_eunlimpos
      integer nf_emaxvars
      integer nf_enotvar
      integer nf_eglobal
      integer nf_enotnc
      integer nf_ests
      integer nf_emaxname
      integer nf_eunlimit
      integer nf_enorecvars
      integer nf_echar
      integer nf_eedge
      integer nf_estride
      integer nf_ebadname
      integer nf_erange
      integer nf_enomem

      parameter (nf_noerr = 0)
      parameter (nf_ebadid = -33)
      parameter (nf_eexist = -35)
      parameter (nf_einval = -36)
      parameter (nf_eperm = -37)
      parameter (nf_enotindefine = -38)
      parameter (nf_eindefine = -39)
      parameter (nf_einvalcoords = -40)
      parameter (nf_emaxdims = -41)
      parameter (nf_enameinuse = -42)
      parameter (nf_enotatt = -43)
      parameter (nf_emaxatts = -44)
      parameter (nf_ebadtype = -45)
      parameter (nf_ebaddim = -46)
      parameter (nf_eunlimpos = -47)
      parameter (nf_emaxvars = -48)
      parameter (nf_enotvar = -49)
      parameter (nf_eglobal = -50)
      parameter (nf_enotnc = -51)
      parameter (nf_ests = -52)
      parameter (nf_emaxname = -53)
      parameter (nf_eunlimit = -54)
      parameter (nf_enorecvars = -55)
      parameter (nf_echar = -56)
      parameter (nf_eedge = -57)
      parameter (nf_estride = -58)
      parameter (nf_ebadname = -59)
      parameter (nf_erange = -60)
      parameter (nf_enomem = -61)

!
! error handling modes:
!
      integer  nf_fatal
      integer nf_verbose

      parameter (nf_fatal = 1)
      parameter (nf_verbose = 2)

!
! miscellaneous routines:
!
      character*80   nf_inq_libvers
      external       nf_inq_libvers

      character*80   nf_strerror
!                         (integer             ncerr)
      external       nf_strerror

      logical        nf_issyserr
!                         (integer             ncerr)
      external       nf_issyserr

!
! control routines:
!
      integer         nf_inq_base_pe
!                         (integer             ncid,
!                          integer             pe)
      external        nf_inq_base_pe

      integer         nf_set_base_pe
!                         (integer             ncid,
!                          integer             pe)
      external        nf_set_base_pe

      integer         nf_create
!                         (character*(*)       path,
!                          integer             cmode,
!                          integer             ncid)
      external        nf_create

      integer         nf__create
!                         (character*(*)       path,
!                          integer             cmode,
!                          integer             initialsz,
!                          integer             chunksizehint,
!                          integer             ncid)
      external        nf__create

      integer         nf__create_mp
!                         (character*(*)       path,
!                          integer             cmode,
!                          integer             initialsz,
!                          integer             basepe,
!                          integer             chunksizehint,
!                          integer             ncid)
      external        nf__create_mp

      integer         nf_open
!                         (character*(*)       path,
!                          integer             mode,
!                          integer             ncid)
      external        nf_open

      integer         nf__open
!                         (character*(*)       path,
!                          integer             mode,
!                          integer             chunksizehint,
!                          integer             ncid)
      external        nf__open

      integer         nf__open_mp
!                         (character*(*)       path,
!                          integer             mode,
!                          integer             basepe,
!                          integer             chunksizehint,
!                          integer             ncid)
      external        nf__open_mp

      integer         nf_set_fill
!                         (integer             ncid,
!                          integer             fillmode,
!                          integer             old_mode)
      external        nf_set_fill

      integer         nf_redef
!                         (integer             ncid)
      external        nf_redef

      integer         nf_enddef
!                         (integer             ncid)
      external        nf_enddef

      integer         nf__enddef
!                         (integer             ncid,
!                          integer             h_minfree,
!                          integer             v_align,
!                          integer             v_minfree,
!                          integer             r_align)
      external        nf__enddef

      integer         nf_sync
!                         (integer             ncid)
      external        nf_sync

      integer         nf_abort
!                         (integer             ncid)
      external        nf_abort

      integer         nf_close
!                         (integer             ncid)
      external        nf_close

      integer         nf_delete
!                         (character*(*)       ncid)
      external        nf_delete

!
! general inquiry routines:
!

      integer         nf_inq
!                         (integer             ncid,
!                          integer             ndims,
!                          integer             nvars,
!                          integer             ngatts,
!                          integer             unlimdimid)
      external        nf_inq

      integer         nf_inq_ndims
!                         (integer             ncid,
!                          integer             ndims)
      external        nf_inq_ndims

      integer         nf_inq_nvars
!                         (integer             ncid,
!                          integer             nvars)
      external        nf_inq_nvars

      integer         nf_inq_natts
!                         (integer             ncid,
!                          integer             ngatts)
      external        nf_inq_natts

      integer         nf_inq_unlimdim
!                         (integer             ncid,
!                          integer             unlimdimid)
      external        nf_inq_unlimdim

!
! dimension routines:
!

      integer         nf_def_dim
!                         (integer             ncid,
!                          character(*)        name,
!                          integer             len,
!                          integer             dimid)
      external        nf_def_dim

      integer         nf_inq_dimid
!                         (integer             ncid,
!                          character(*)        name,
!                          integer             dimid)
      external        nf_inq_dimid

      integer         nf_inq_dim
!                         (integer             ncid,
!                          integer             dimid,
!                          character(*)        name,
!                          integer             len)
      external        nf_inq_dim

      integer         nf_inq_dimname
!                         (integer             ncid,
!                          integer             dimid,
!                          character(*)        name)
      external        nf_inq_dimname

      integer         nf_inq_dimlen
!                         (integer             ncid,
!                          integer             dimid,
!                          integer             len)
      external        nf_inq_dimlen

      integer         nf_rename_dim
!                         (integer             ncid,
!                          integer             dimid,
!                          character(*)        name)
      external        nf_rename_dim

!
! general attribute routines:
!

      integer         nf_inq_att
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len)
      external        nf_inq_att

      integer         nf_inq_attid
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             attnum)
      external        nf_inq_attid

      integer         nf_inq_atttype
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype)
      external        nf_inq_atttype

      integer         nf_inq_attlen
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             len)
      external        nf_inq_attlen

      integer         nf_inq_attname
!                         (integer             ncid,
!                          integer             varid,
!                          integer             attnum,
!                          character(*)        name)
      external        nf_inq_attname

      integer         nf_copy_att
!                         (integer             ncid_in,
!                          integer             varid_in,
!                          character(*)        name,
!                          integer             ncid_out,
!                          integer             varid_out)
      external        nf_copy_att

      integer         nf_rename_att
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        curname,
!                          character(*)        newname)
      external        nf_rename_att

      integer         nf_del_att
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name)
      external        nf_del_att

!
! attribute put/get routines:
!

      integer         nf_put_att_text
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             len,
!                          character(*)        text)
      external        nf_put_att_text

      integer         nf_get_att_text
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          character(*)        text)
      external        nf_get_att_text

      integer         nf_put_att_int1
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          nf_int1_t           i1vals(1))
      external        nf_put_att_int1

      integer         nf_get_att_int1
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          nf_int1_t           i1vals(1))
      external        nf_get_att_int1

      integer         nf_put_att_int2
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          nf_int2_t           i2vals(1))
      external        nf_put_att_int2

      integer         nf_get_att_int2
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          nf_int2_t           i2vals(1))
      external        nf_get_att_int2

      integer         nf_put_att_int
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          integer             ivals(1))
      external        nf_put_att_int

      integer         nf_get_att_int
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             ivals(1))
      external        nf_get_att_int

      integer         nf_put_att_real
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          real                rvals(1))
      external        nf_put_att_real

      integer         nf_get_att_real
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          real                rvals(1))
      external        nf_get_att_real

      integer         nf_put_att_double
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             xtype,
!                          integer             len,
!                          double              dvals(1))
      external        nf_put_att_double

      integer         nf_get_att_double
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          double              dvals(1))
      external        nf_get_att_double

!
! general variable routines:
!

      integer         nf_def_var
!                         (integer             ncid,
!                          character(*)        name,
!                          integer             datatype,
!                          integer             ndims,
!                          integer             dimids(1),
!                          integer             varid)
      external        nf_def_var

      integer         nf_inq_var
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name,
!                          integer             datatype,
!                          integer             ndims,
!                          integer             dimids(1),
!                          integer             natts)
      external        nf_inq_var

      integer         nf_inq_varid
!                         (integer             ncid,
!                          character(*)        name,
!                          integer             varid)
      external        nf_inq_varid

      integer         nf_inq_varname
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name)
      external        nf_inq_varname

      integer         nf_inq_vartype
!                         (integer             ncid,
!                          integer             varid,
!                          integer             xtype)
      external        nf_inq_vartype

      integer         nf_inq_varndims
!                         (integer             ncid,
!                          integer             varid,
!                          integer             ndims)
      external        nf_inq_varndims

      integer         nf_inq_vardimid
!                         (integer             ncid,
!                          integer             varid,
!                          integer             dimids(1))
      external        nf_inq_vardimid

      integer         nf_inq_varnatts
!                         (integer             ncid,
!                          integer             varid,
!                          integer             natts)
      external        nf_inq_varnatts

      integer         nf_rename_var
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        name)
      external        nf_rename_var

      integer         nf_copy_var
!                         (integer             ncid_in,
!                          integer             varid,
!                          integer             ncid_out)
      external        nf_copy_var

!
! entire variable put/get routines:
!

      integer         nf_put_var_text
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        text)
      external        nf_put_var_text

      integer         nf_get_var_text
!                         (integer             ncid,
!                          integer             varid,
!                          character(*)        text)
      external        nf_get_var_text

      integer         nf_put_var_int1
!                         (integer             ncid,
!                          integer             varid,
!                          nf_int1_t           i1vals(1))
      external        nf_put_var_int1

      integer         nf_get_var_int1
!                         (integer             ncid,
!                          integer             varid,
!                          nf_int1_t           i1vals(1))
      external        nf_get_var_int1

      integer         nf_put_var_int2
!                         (integer             ncid,
!                          integer             varid,
!                          nf_int2_t           i2vals(1))
      external        nf_put_var_int2

      integer         nf_get_var_int2
!                         (integer             ncid,
!                          integer             varid,
!                          nf_int2_t           i2vals(1))
      external        nf_get_var_int2

      integer         nf_put_var_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             ivals(1))
      external        nf_put_var_int

      integer         nf_get_var_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             ivals(1))
      external        nf_get_var_int

      integer         nf_put_var_real
!                         (integer             ncid,
!                          integer             varid,
!                          real                rvals(1))
      external        nf_put_var_real

      integer         nf_get_var_real
!                         (integer             ncid,
!                          integer             varid,
!                          real                rvals(1))
      external        nf_get_var_real

      integer         nf_put_var_double
!                         (integer             ncid,
!                          integer             varid,
!                          doubleprecision     dvals(1))
      external        nf_put_var_double

      integer         nf_get_var_double
!                         (integer             ncid,
!                          integer             varid,
!                          doubleprecision     dvals(1))
      external        nf_get_var_double

!
! single variable put/get routines:
!

      integer         nf_put_var1_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          character*1         text)
      external        nf_put_var1_text

      integer         nf_get_var1_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          character*1         text)
      external        nf_get_var1_text

      integer         nf_put_var1_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          nf_int1_t           i1val)
      external        nf_put_var1_int1

      integer         nf_get_var1_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          nf_int1_t           i1val)
      external        nf_get_var1_int1

      integer         nf_put_var1_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          nf_int2_t           i2val)
      external        nf_put_var1_int2

      integer         nf_get_var1_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          nf_int2_t           i2val)
      external        nf_get_var1_int2

      integer         nf_put_var1_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          integer             ival)
      external        nf_put_var1_int

      integer         nf_get_var1_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          integer             ival)
      external        nf_get_var1_int

      integer         nf_put_var1_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          real                rval)
      external        nf_put_var1_real

      integer         nf_get_var1_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          real                rval)
      external        nf_get_var1_real

      integer         nf_put_var1_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          doubleprecision     dval)
      external        nf_put_var1_double

      integer         nf_get_var1_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             index(1),
!                          doubleprecision     dval)
      external        nf_get_var1_double

!
! variable array put/get routines:
!

      integer         nf_put_vara_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          character(*)        text)
      external        nf_put_vara_text

      integer         nf_get_vara_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          character(*)        text)
      external        nf_get_vara_text

      integer         nf_put_vara_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          nf_int1_t           i1vals(1))
      external        nf_put_vara_int1

      integer         nf_get_vara_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          nf_int1_t           i1vals(1))
      external        nf_get_vara_int1

      integer         nf_put_vara_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          nf_int2_t           i2vals(1))
      external        nf_put_vara_int2

      integer         nf_get_vara_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          nf_int2_t           i2vals(1))
      external        nf_get_vara_int2

      integer         nf_put_vara_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             ivals(1))
      external        nf_put_vara_int

      integer         nf_get_vara_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             ivals(1))
      external        nf_get_vara_int

      integer         nf_put_vara_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          real                rvals(1))
      external        nf_put_vara_real

      integer         nf_get_vara_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          real                rvals(1))
      external        nf_get_vara_real

      integer         nf_put_vara_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          doubleprecision     dvals(1))
      external        nf_put_vara_double

      integer         nf_get_vara_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          doubleprecision     dvals(1))
      external        nf_get_vara_double

!
! strided variable put/get routines:
!

      integer         nf_put_vars_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          character(*)        text)
      external        nf_put_vars_text

      integer         nf_get_vars_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          character(*)        text)
      external        nf_get_vars_text

      integer         nf_put_vars_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          nf_int1_t           i1vals(1))
      external        nf_put_vars_int1

      integer         nf_get_vars_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          nf_int1_t           i1vals(1))
      external        nf_get_vars_int1

      integer         nf_put_vars_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          nf_int2_t           i2vals(1))
      external        nf_put_vars_int2

      integer         nf_get_vars_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          nf_int2_t           i2vals(1))
      external        nf_get_vars_int2

      integer         nf_put_vars_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             ivals(1))
      external        nf_put_vars_int

      integer         nf_get_vars_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             ivals(1))
      external        nf_get_vars_int

      integer         nf_put_vars_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          real                rvals(1))
      external        nf_put_vars_real

      integer         nf_get_vars_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          real                rvals(1))
      external        nf_get_vars_real

      integer         nf_put_vars_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          doubleprecision     dvals(1))
      external        nf_put_vars_double

      integer         nf_get_vars_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          doubleprecision     dvals(1))
      external        nf_get_vars_double

!
! mapped variable put/get routines:
!

      integer         nf_put_varm_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          character(*)        text)
      external        nf_put_varm_text

      integer         nf_get_varm_text
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          character(*)        text)
      external        nf_get_varm_text

      integer         nf_put_varm_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          nf_int1_t           i1vals(1))
      external        nf_put_varm_int1

      integer         nf_get_varm_int1
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          nf_int1_t           i1vals(1))
      external        nf_get_varm_int1

      integer         nf_put_varm_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          nf_int2_t           i2vals(1))
      external        nf_put_varm_int2

      integer         nf_get_varm_int2
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          nf_int2_t           i2vals(1))
      external        nf_get_varm_int2

      integer         nf_put_varm_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          integer             ivals(1))
      external        nf_put_varm_int

      integer         nf_get_varm_int
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          integer             ivals(1))
      external        nf_get_varm_int

      integer         nf_put_varm_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          real                rvals(1))
      external        nf_put_varm_real

      integer         nf_get_varm_real
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          real                rvals(1))
      external        nf_get_varm_real

      integer         nf_put_varm_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          doubleprecision     dvals(1))
      external        nf_put_varm_double

      integer         nf_get_varm_double
!                         (integer             ncid,
!                          integer             varid,
!                          integer             start(1),
!                          integer             count(1),
!                          integer             stride(1),
!                          integer             imap(1),
!                          doubleprecision     dvals(1))
      external        nf_get_varm_double

!ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
! begin netcdf 2.4 backward compatibility:
!

!      
! functions in the fortran interface
!
      integer nccre
      integer ncopn
      integer ncddef
      integer ncdid
      integer ncvdef
      integer ncvid
      integer nctlen
      integer ncsfil

      external nccre
      external ncopn
      external ncddef
      external ncdid
      external ncvdef
      external ncvid
      external nctlen
      external ncsfil


      integer ncrdwr
      integer nccreat
      integer ncexcl
      integer ncindef
      integer ncnsync
      integer nchsync
      integer ncndirty
      integer nchdirty
      integer nclink
      integer ncnowrit
      integer ncwrite
      integer ncclob
      integer ncnoclob
      integer ncglobal
      integer ncfill
      integer ncnofill
      integer maxncop
      integer maxncdim
      integer maxncatt
      integer maxncvar
      integer maxncnam
      integer maxvdims
      integer ncnoerr
      integer ncebadid
      integer ncenfile
      integer nceexist
      integer nceinval
      integer nceperm
      integer ncenotin
      integer nceindef
      integer ncecoord
      integer ncemaxds
      integer ncename
      integer ncenoatt
      integer ncemaxat
      integer ncebadty
      integer ncebadd
      integer ncests
      integer nceunlim
      integer ncemaxvs
      integer ncenotvr
      integer nceglob
      integer ncenotnc
      integer ncfoobar
      integer ncsyserr
      integer ncfatal
      integer ncverbos
      integer ncentool


!
! netcdf data types:
!
      integer ncbyte
      integer ncchar
      integer ncshort
      integer nclong
      integer ncfloat
      integer ncdouble

      parameter(ncbyte = 1)
      parameter(ncchar = 2)
      parameter(ncshort = 3)
      parameter(nclong = 4)
      parameter(ncfloat = 5)
      parameter(ncdouble = 6)

!     
!     masks for the struct nc flag field; passed in as 'mode' arg to
!     nccreate and ncopen.
!     

!     read/write, 0 => readonly 
      parameter(ncrdwr = 1)
!     in create phase, cleared by ncendef 
      parameter(nccreat = 2)
!     on create destroy existing file 
      parameter(ncexcl = 4)
!     in define mode, cleared by ncendef 
      parameter(ncindef = 8)
!     synchronise numrecs on change (x'10')
      parameter(ncnsync = 16)
!     synchronise whole header on change (x'20')
      parameter(nchsync = 32)
!     numrecs has changed (x'40')
      parameter(ncndirty = 64)  
!     header info has changed (x'80')
      parameter(nchdirty = 128)
!     prefill vars on endef and increase of record, the default behavior
      parameter(ncfill = 0)
!     do not fill vars on endef and increase of record (x'100')
      parameter(ncnofill = 256)
!     isa link (x'8000')
      parameter(nclink = 32768)

!     
!     'mode' arguments for nccreate and ncopen
!     
      parameter(ncnowrit = 0)
      parameter(ncwrite = ncrdwr)
      parameter(ncclob = nf_clobber)
      parameter(ncnoclob = nf_noclobber)

!     
!     'size' argument to ncdimdef for an unlimited dimension
!     
      integer ncunlim
      parameter(ncunlim = 0)

!     
!     attribute id to put/get a global attribute
!     
      parameter(ncglobal  = 0)

!     
!     advisory maximums:
!     
      parameter(maxncop = 32)
      parameter(maxncdim = 100)
      parameter(maxncatt = 2000)
      parameter(maxncvar = 2000)
!     not enforced 
      parameter(maxncnam = 128)
      parameter(maxvdims = maxncdim)

!     
!     global netcdf error status variable
!     initialized in error.c
!     

!     no error 
      parameter(ncnoerr = nf_noerr)
!     not a netcdf id 
      parameter(ncebadid = nf_ebadid)
!     too many netcdfs open 
      parameter(ncenfile = -31)   ! nc_syserr
!     netcdf file exists && ncnoclob
      parameter(nceexist = nf_eexist)
!     invalid argument 
      parameter(nceinval = nf_einval)
!     write to read only 
      parameter(nceperm = nf_eperm)
!     operation not allowed in data mode 
      parameter(ncenotin = nf_enotindefine )   
!     operation not allowed in define mode 
      parameter(nceindef = nf_eindefine)   
!     coordinates out of domain 
      parameter(ncecoord = nf_einvalcoords)
!     maxncdims exceeded 
      parameter(ncemaxds = nf_emaxdims)
!     string match to name in use 
      parameter(ncename = nf_enameinuse)   
!     attribute not found 
      parameter(ncenoatt = nf_enotatt)
!     maxncattrs exceeded 
      parameter(ncemaxat = nf_emaxatts)
!     not a netcdf data type 
      parameter(ncebadty = nf_ebadtype)
!     invalid dimension id 
      parameter(ncebadd = nf_ebaddim)
!     ncunlimited in the wrong index 
      parameter(nceunlim = nf_eunlimpos)
!     maxncvars exceeded 
      parameter(ncemaxvs = nf_emaxvars)
!     variable not found 
      parameter(ncenotvr = nf_enotvar)
!     action prohibited on ncglobal varid 
      parameter(nceglob = nf_eglobal)
!     not a netcdf file 
      parameter(ncenotnc = nf_enotnc)
      parameter(ncests = nf_ests)
      parameter (ncentool = nf_emaxname) 
      parameter(ncfoobar = 32)
      parameter(ncsyserr = -31)

!     
!     global options variable. used to determine behavior of error handler.
!     initialized in lerror.c
!     
      parameter(ncfatal = 1)
      parameter(ncverbos = 2)

!
!     default fill values.  these must be the same as in the c interface.
!
      integer filbyte
      integer filchar
      integer filshort
      integer fillong
      real filfloat
      doubleprecision fildoub

      parameter (filbyte = -127)
      parameter (filchar = 0)
      parameter (filshort = -32767)
      parameter (fillong = -2147483647)
      parameter (filfloat = 9.9692099683868690e+36)
      parameter (fildoub = 9.9692099683868690e+36)
   if (iret .ne. NF_NOERR) then
   print *, nf_strerror(iret)
   stop
   endif
   end


!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!----------------------------------------------------------------------- 
