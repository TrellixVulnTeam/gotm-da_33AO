# This code is written in Python 3, but for Python 2.6 or above, we need...
from __future__ import print_function
try:
    FileNotFoundError
except NameError:
    FileNotFoundError = IOError

### Global settings
import os

## For general GOTM setup

# Set the default GOTM executable and namelist locations.
userhome = os.getenv('HOME')
project_folder = os.path.join(userhome,'gotm-dst')
GOTM_executable = os.path.join(project_folder,'bin','gotm')
if not(os.path.isfile(GOTM_executable)):
    raise FileNotFoundError("The GOTM executable not found at " + GOTM_executable)
GOTM_nml_path = os.path.join(project_folder,'config')
GOTM_nml_list = ['gotmrun.inp','gotmmean.inp','gotmturb.inp','airsea.inp','obs.inp']
for nml in GOTM_nml_list:
    GOTM_nml_template = os.path.join(GOTM_nml_path,nml)
    if not(os.path.isfile(GOTM_nml_template)):
           raise FileNotFoundError("The GOTM config namelist " + GOTM_nml_template + " is invalid.")

## For medsea simulations

# Top-level project folders
base_folder = os.path.join(project_folder,'medsea_GOTM')
if not(os.path.isdir(base_folder)):
    raise IOError('The base folder: ' + base_folder + 'is either not accessible or created.')
run_folder = os.path.join(base_folder,'run')
if not(os.path.isdir(run_folder)):
    os.mkdir(run_folder)
    
# Global setting for the core_dat() routines (and possibly the ERA routines as well)
overwrite=True

# Our grid points. Maybe we can reduce dependence on numpy by just using a Python array.
medsea_lats = tuple(30.75+0.75*i for i in range(21))
medsea_lons = tuple(-6.0+0.75*i for i in range(57))

### General GOTM wrappers

# Running GOTM console through a subprocess as if we were in a linux terminal.
def run_command(cmd, output='PIPE'): 
    " Execute a command as a subprocess and directing output to a pipe or a log file. "
    from subprocess import Popen, PIPE, STDOUT
    import shlex,os,_io

    # For backward-compatibility.
    if isinstance(output,bool) and output == True:
        output = 'PIPE'
    
    # New code block for Python 2
    ## Open a subprocess.
    #if output == 'PIPE':
    #    p = Popen(shlex.split(cmd), stdout=PIPE, stderr=STDOUT, bufsize=1, universal_newlines=True)
    #    for line in p.stdout:
    #        print(line,end='')
    #elif isinstance(output,_io.TextIOWrapper) or isinstance(output,file): # Python 2/3 discrepancy here.
    #    p = Popen(shlex.split(cmd), stdout=output, stderr=STDOUT, bufsize=1, universal_newlines=True)
    #    #p.wait()
    #    #output.flush()
    #else:
    #    p = Popen(shlex.split(cmd), stdout=None, stderr=None)
    #
    #exit_code = p.poll()
    #if not(exit_code==0) and not(exit_code is None): #debug
    #    print('exit_code: ', exit_code, type(exit_code)) 
    #    raise RuntimeError("Command: " + cmd + " failed.")

    # The following does not work with Python <= 3.2
    # To a console
    if output == 'PIPE':
        with Popen(shlex.split(cmd), stdout=PIPE, stderr=STDOUT, bufsize=1, universal_newlines=True) as p:
            for line in p.stdout:
                print(line, end='')
            exit_code = p.poll()
    # To a file.
    elif isinstance(output,_io.TextIOWrapper) or isinstance(output,file): # Python 2/3 discrepancy here.
        with Popen(shlex.split(cmd), stdout=output, stderr=STDOUT) as p:
            exit_code = p.poll()    
    # To nothing, just run it.
    else:
        with Popen(shlex.split(cmd), stdout=None, stderr=None) as p:
            exit_code = p.poll()     

    return exit_code

# This function should be extended to output a simulation object, encapsulating the run options and the results in 
# one class. This will in turn allow us to run continuation calls easily.
def gotm(varsout = {}, run_folder = '.', verbose = False, logfn = 'gotm.log',
         GOTM_executable = GOTM_executable, inp_templates = None, inp_backup = False, **gotm_args):
    """ Runs GOTM in with extra functions. """
    import os, shutil
    
    # Remember the current working folder then walk into the run folder.
    home = os.getcwd() 
    if os.path.isdir(run_folder):
        os.chdir(run_folder)   
    else:
        raise IOError("The folder path: " + run_folder + " is invalid.")
    
    # Check for GOTM config namelists in the local run_folder.
    #GOTM_nml_list = ['gotmrun.inp','gotmmean.inp','gotmturb.inp','airsea.inp','obs.inp'] # Moved to the top, as global var.
    for each in GOTM_nml_list:
        if not(os.path.isfile(each)):
            shutil.copyfile(os.path.join(inp_templates,each),os.path.join(run_folder,each))
    
    # Update the config as well if user specified extra options.
    if gotm_args:
        new_cfg = updatecfg(path = run_folder, inp_backup = inp_backup, verbose = verbose, **gotm_args)
    
    # Now run the GOTM executable in this folder.
    if verbose:       
        run_command(GOTM_executable,output='PIPE')
    else:
        with open(logfn,'w') as logfile:
            run_command(GOTM_executable,output=logfile)
    
    # Return to the original working directory.
    os.chdir(home)
    
    # Check whether a result file is created. Should be replaced by a better exception handling structure.
    from netCDF4 import Dataset
    dr = getval(loadcfg(verbose=False),'out_dir')
    fn = getval(loadcfg(verbose=False),'out_fn') + '.nc'
    with Dataset(os.path.join(dr,fn),'r') as results:
        #print('len of time in results = ',len(results['time'])>0)
        if len(results['time']) == 0:
            raise Exception("Invalid GOTM results! Time dimension is empty. GOTM failed?")
        #dims = set()
        #varsout = set(varsout)
        #for var in varsout:
        #    dims = dims.union(results[var].dimensions)
        # also save the dimension variables to output.
        #varsout = varsout.union(dims)

        #print(dims)
        #print(varsout)

        #dim_dict = dict()
        #for dim in dims:
        # print('Retrieving {}... with shape {}'.format(dim,shape(results[dim])))
        #    dim_dict[dim] = results[dim][:]
        #    
        #var_dict = {var: {'values': results[var][:], 
        #                  'dimensions': results[var].dimensions,
        #                  'units': results[var].units} for var in list(varsout)}
        # 
        #return (dim_dict, var_dict) 
    return
      
## Treating f90 namelists used by GOTM 3.0.0
    
def loadcfg(path='.', verbose = True):
    from f90nml import read
    from os.path import join
    config = dict()
    for eachnml in GOTM_nml_list:
        fn = join(path,eachnml)
        if verbose:
            print('Reading {} ...'.format(fn))
        ### Warning! Keep failing to an infinite loop if the file is empty for some reason!
        config[eachnml] = read(fn)
    return config

def writecfg(gotm_cfg, path='.', inp_backup = False, verbose = True):
    from f90nml import write
    from os.path import exists, join
    from os import rename
    from datetime import datetime
    timestr = datetime.now().strftime("%Y%m%dT%H%M%S") 
    for eachnml in GOTM_nml_list:
        fullfile = join(path,eachnml)
        if exists(fullfile) and inp_backup:
            # Append a suffix with the current timestamp, almost ISO8601-like, sans '-', ':' and timezone.
            rename(fullfile,fullfile[:-4] + '_' + timestr + '.inp')    
        write(gotm_cfg[eachnml],fullfile,force=True)
    if verbose:
        if inp_backup:
            print('A backup set of namelists saved at ' + timestr)
        print('GOTM config written.')
        
        
def updatecfg(path='.', inp_backup = False, verbose = True, **kwargs):
    # NOTE: Currently, this method can update multiple key/value pairs if the key names repeat among the files, i.e.
    # We assume, in spite of the hierarchy of namelists, that the name of the keys are unique across hierarchies and
    # namelist files.
    #
    # For example: 
    #
    # updatecfg(gotm_cfg, start='2014-01-01 00:00:00') will update the 'start' value in `gotmrun.inp` but will also 
    # update the 'start' value in in, say, `obs.inp` as well if it exists (luckily. this is not true).
    # Though very unlikely, still it is better to perform a test flattening the nested namelist structure to 
    # confirm the key/value pairs at leaf node level do not repeat in the name of the keys, even across several files. 
    
    #print(kwargs, ' in updatecfg()')
    import f90nml
    from os import rename, remove
    from os.path import join
    from datetime import datetime
    list_of_keys_to_update = list(kwargs.keys())
    #print(kwargs) #debug
    def recursively_update(nml, **kwargs):
        for k,v in nml.items():
            has_key = list_of_keys_to_update.count(k)
            if isinstance(v,f90nml.namelist.Namelist):
            #if isinstance(v,f90nml.NmlDict):
                new_cfg = recursively_update(v, **kwargs)
            elif has_key == 0:
                continue
            else:
                assert has_key == 1
                nml[k] = kwargs[k]
        return nml
    newcfg = recursively_update(loadcfg(path=path, verbose=False), **kwargs)
    for eachnml in GOTM_nml_list:
        inp = join(path,eachnml)
        timestr = datetime.now().strftime("%Y%m%dT%H%M%S")
        inpbkp = inp[:-4] + '_' + timestr + '.inp'
        rename(inp,inpbkp) 
        f90nml.patch(inpbkp,newcfg[eachnml],inp)
#        f90nml.write(newcfg[eachnml],inp)
        if not(inp_backup):
            remove(inpbkp)
        if verbose:
            if inp_backup:
                print('A backup set of namelists saved at ' + timestr)
            print('GOTM config updated by patching.')
            
            
    return 

def getval(gotm_cfg, key):
    "Return the value and walking through the hierarchy of the namelists."
    import f90nml
    # This is quite Fortran style. Maybe should use return values instead.
    result = []; # List is mutable and the nonlocal keyword allow the recursive calls to bind to THIS variable.
    def recursively_find_in(nml):
        for k,v in nml.items():
            if isinstance(v,f90nml.namelist.Namelist):
                recursively_find_in(v)
            elif k == key:
                result.append(v)
    recursively_find_in(gotm_cfg)
    if len(result) == 0:
        return None
    else: 
        assert(len(result) == 1) # Expect unique key names
        return result[0] 

### Medsea run functions

## Helper functions
def change_base(new_base_folder):
    global base_folder, run_folder
    if not(os.path.isdir(new_base_folder)):
        raise IOError('The base folder: ' + new_base_folder + 'is either not accessible or created.')
    base_folder = new_base_folder
    run_folder=os.path.join(base_folder,'run')
    if not(os.path.isdir(run_folder)):
        os.mkdir(run_folder)

def timestr(nctime,i):
    " Return a formatted time string from a nc time variable at index i."
    from netCDF4 import datetime, num2date
    return datetime.strftime(num2date(nctime[i],nctime.units),'%Y-%m-%d %H:%M:%S')        
        
def print_lat_lon(lat,lon,fmt_str='.2f'):
    "Helper function for printing (lat,lon) as 10.5N2.1E etc. "

    # if not(isinstance(lat,float)):
    #     raise Exception("`lat` is of type " + str(type(lat)))
    # if not(isinstance(lon,float)):
    #     raise Exception("`lon` is of type " + str(type(lon)))
    lat = float(lat)
    lon = float(lon)
    
    template = '{:' + fmt_str + '}'
    lat_str = template.format(lat) + 'N' if lat>=0 else template.format(-lat) + 'S'
    lon_str = template.format(lon) + 'E' if lon>=0 else template.format(-lon) + 'W'
    #return lat_str + ' ' + lon_str
    return lat_str + lon_str

def prepare_engine():
    " Prepare ipyparallel engines by importing settings and dependencies. "
    from ipyparallel import Client
    rc = Client()
    dv = rc[:]
    lv = rc.load_balanced_view()

    dv.execute('import os,sys')
    dv.execute("userhome = os.getenv('HOME')")
    dv.execute("project_folder = 'gotm-dst'")
    dv.execute("sys.path.append(os.path.join(userhome,project_folder,'src'))")
    dv.execute('os.chdir("{}")'.format(base_folder))
    dv.execute('from gotm import *')
    dv.execute('change_base("{}")'.format(base_folder))
    return rc, lv


## Medsea parallel run toolbox
def get_core_folder(year,month,lat,lon):
    """ Create folder structure initially or mid-way (if not yet done). 
        The innermost subfolder, which is called 'core_folder' is 
        where a GOTM run is executed for one grid point per time period.  
        It contains settings (*.inp), input data (*.dat) and output data (*.nc) """
    # Temporary hack, be forgiving if the provided lat, lon are actually indices of our medsea grid.
    if isinstance(lat,int):
        lat = medsea_lats[lat]
    if isinstance(lon,int):
        lon = medsea_lons[lon]
        
    monthly_folder = os.path.join(run_folder,'{:d}{:02d}'.format(year,month))
    if not(os.path.isdir(monthly_folder)):
        os.mkdir(monthly_folder)
    latlong = print_lat_lon(lat,lon)
    core_folder = os.path.join(monthly_folder,latlong)
    if not(os.path.isdir(core_folder)):
        os.mkdir(core_folder)
    return core_folder 

def core_dat(year,month,m,n,**nc_dict):
    """
    Generate *.dat files for each core folder. 
    The critical keyword argument 'nc_dict' provides dat filename to nc Dataset
    handle correspondance, e.g. {'heat': heat_nc} where 
                   heat_nc = Dataset('ERA_heat_yyyymm.nc','r') 
    has been run before calling this function. The file 'heat.dat' would be generated by
    using information from 'ERA_heat_yyyymm.nc', and recipe defined in an inner function.
    """
    from netCDF4 import num2date, datetime, Dataset
    from os.path import isfile
    
    # Get the location of the core_folder.
    lat = medsea_lats[m]
    lon = medsea_lons[n]
    latlong = print_lat_lon(lat,lon)
    core_folder = get_core_folder(year,month,lat,lon) 

    def writedat(dat_fn):
        nc = nc_dict[dat_fn]
        if isinstance(nc,Dataset):
            time = nc['time']
        elif isfile(nc):
            nc = Dataset(nc,'r')
            time = nc['time']
        fn = os.path.join(core_folder,dat_fn+'.dat')
        if isfile(fn) and not overwrite:
            print(fn + " exists, skipping.\n")
            return    

        with open(fn,'w') as f:
            # Recipes for each type of dat file.
            print(fn) # Print the filename for debug.
            if dat_fn == 'tprof':
                for i in range(len(time)):
                    f.write(timestr(time,i) + ' 18 2\n') # Always 18 readings and two columns.
                    for j in range(18):
                        line = ('{:g}'*2).format(-nc['depth'][j],nc['votemper'][i,j,m,n])
                        f.write(line)
            elif dat_fn == 'sprof':
                for i in range(len(time)):
                    f.write(timestr(time,i) + ' 18 2\n') # Always 18 readings and two columns.
                    for j in range(18):
                        line = ('{:g}'*2).format(-nc['depth'][j],nc['vosaline'][i,j,m,n])
                        f.write(line)
            elif dat_fn == 'heat':
                col = [None for i in range(4)]
                for i in range(len(time)):
                    col[0] = timestr(time,i)
                    col[1] = nc['swrd'][i,m,n]
                    col[2] = 1 if 'cloud_factor' not in nc.variables else nc['cloud_factor'][i,m,n]
                    col[3] = nc['lwrd'][i,m,n]
                    print(*col)
                    line = ('{:s} {:g} {:g} {:g}').format(*col)
                    f.write(line)
            elif dat_fn == 'met':
                col = [None for i in range(9)]
                for i in range(len(time)):
                    col[0] = timestr(time,i)
                    col[1] = nc['u10m'][i,m,n]
                    col[2] = nc['v10m'][i,m,n]
                    col[3] = nc['sp'][i,m,n]/100 # surface pressure, convert from Pa to hPa
                    col[4] = nc['t2m'][i,m,n] - 273.15 # air temperature at 2m, convert to Celsius
                    col[5] = nc['q2m'][i,m,n] # specific humidity at 2m
                    col[6] = 0 # "cloud" value?
                    col[7] = nc['precip'][i,m,n]
                    col[8] = nc['snow'][i,m,n]
                    line = ('{:s}'+' {:g}'*8).format(*col)
                    f.write(line)
            elif dat_fn == 'sst':
                for i in range(len(time)):
                    line = '{:s} {:g}'.format(timestr(time,i),nc['analysed_sst'][i,m,n])
                    f.write(line)
            elif dat_fn == 'chlo':
                for i in range(len(time)):
                    line = '{:s} {:g}'.format(timestr(time,i),nc['chlor_a'][i,m,n])
                    f.write(line)
            else:
                raise Exception("Requested {}.dat has no recipes defined in core_dat()".format(dat_fn))
        print('Done writing {}.\n'.format(fn))
    
    for dat_fn in nc_dict.keys():
        # print(dat_fn)
        writedat(dat_fn)
        
    return

def medsea_dat(year=2014, month=1, engine=None):
    " Generate vaious GOTM dat files for all medsea grid points, using load-balanced ipyparallel engines. "
    import itertools, os
    from netCDF4 import Dataset
    if engine is None:
        client, engine = prepare_engine()
    mm,nn = zip(*itertools.product(range(21),range(57)))
    print('Generating dat files for {0:d}{1:02d} ...'.format(year,month))
    print('Using netCDF files from ' + base_folder)
    # The dat files and corresponding netCDF dataset sources.
    data_sources = \
    {'heat' : os.path.join(base_folder,'forcing', 'medsea_ERA_heat_{:d}{:02d}.nc'.format(year,month)),
     'met'  : os.path.join(base_folder,'forcing', 'medsea_ERA_meteo_{:d}{:02d}.nc'.format(year,month)),
     'tprof': os.path.join(base_folder,'profiles', 'medsea_rea_votemper_{:d}{:02d}.nc'.format(year,month)),
     'sprof': os.path.join(base_folder,'profiles', 'medsea_rea_vosaline_{:d}{:02d}.nc'.format(year,month)),
     'sst'  : os.path.join(base_folder,'profiles', 'medsea_OSTIA_sst_{:d}{:02d}.nc'.format(year,month)),
     'chlo' : os.path.join(base_folder,'forcing', 'medsea_MODIS_chlor_a_{:d}{:02d}.nc'.format(year,month))}
    
    results = list()
    for dat in data_sources.keys():
        results[dat] = engine.map(core_dat,
                                  itertools.repeat(year,21*57),
                                  itertools.repeat(month,21*57),
                                  mm,nn,itertools.repeat(data_sources,21*57))
    #results.wait_interactive()
    return results

def core_results(year,month,m,n,outfn='results'):
    " Convenience function for getting a netCDF dataset handle for the current core folder result."
    import os
    from netCDF4 import Dataset
    return Dataset(os.path.join(get_core_folder(year,month,m,n),outfn+'.nc'),'r')

def medsea_data(year=2014,month=1,results_folder='ASM0'):
    " Convenience function for getting a netCDF dataset handle for a monthly output."
    import os
    from netCDF4 import Dataset
    fn = os.path.join(base_folder,results_folder, 'medsea_GOTM_{:d}{:02d}.nc'.format(year,month))
    return Dataset(nc_fn,'r')