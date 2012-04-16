function projection = plotOptions(ax,v,varargin)


opts = getappdata(ax);

set(ax,'dataaspectratio',[1 1 1]);

if isfield(opts,'projection')
  
  projection = opts.projection;
  
else
  
  projection.type       = get_option(varargin,'projection','earea');
  
  if isa(v,'S2Grid') &&  get(v,'maxtheta')  <= pi/2
  
    hemisphere = 'north';
  
  elseif check_option(v.options,{'north','south','antipodal','lower','upper'})
    
    hemisphere = extract_option(v,{'north','south','antipodal','lower','upper'});
    
  elseif check_option(varargin,'antipodal')
    
    hemisphere = 'antipodal';
    
  elseif check_option(varargin,'plain')
    
    hemisphere = {'north','south'};
    
  elseif check_option(varargin,{'north','south','antipodal','lower','upper'})
    
    hemisphere = extract_option(varargin,{'north','south','antipodal','lower','upper'});
    
  else
    
    hemisphere = 'both';
    
  end
  
  projection.hemisphere = hemisphere;
  
  if isa(v,'S2Grid')
    projection.mintheta   = get_option(varargin,'mintheta',get(v,'mintheta'));
    
    mth = get(v,'maxtheta');
    if check_option(ensurecell(projection.hemisphere),{'both','north','south'})
      mth = pi/2;
    end
    projection.maxtheta   = get_option(varargin,'maxtheta',mth);
    projection.minrho     = get_option(varargin,'minrho',get(v,'minrho'));
    projection.maxrho     = get_option(varargin,'maxrho',get(v,'maxrho'));
  else
    projection.mintheta   = get_option(varargin,'mintheta',0);
    projection.maxtheta   = get_option(varargin,'maxtheta',pi/2);
    projection.minrho     = get_option(varargin,'minrho',0);
    projection.maxrho     = get_option(varargin,'maxrho',2*pi);
  end
  
  if strcmpi(projection.type,'plain')    
    if check_option(ensurecell(projection.hemisphere),{'south','both'})
      projection.maxtheta = pi;
    end
  end
    
  
  if isa(projection.maxtheta,'function_handle')
    projection.hemisphere = 'north';
  end
   
  plotOptions = get_mtex_option('default_Plot_Options');

  projection.flipud = check_option([varargin plotOptions],'flipud');
  projection.fliplr = check_option([varargin plotOptions],'fliplr');
  projection.drho = get_option(varargin,'rotate',get_option(plotOptions,'rotate',0));
  
  setappdata(ax,'projection',projection)
end

