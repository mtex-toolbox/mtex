function [projection,colorRange] = plotOptions(ax,v,varargin)

% get stored options
opts = getappdata(ax);

% some basic settings
set(ax,'dataaspectratio',[1 1 1]);

%% color range

% set caxis according to colorrange
if check_option(varargin,'colorrange','double')
  colorRange = get_option(varargin,'colorrange',[],'double');
  if colorRange(2)-colorRange(1) < 1e-15
    caxis(ax,[min(colorRange(1),0),max(colorRange(2),1)]);
  elseif ~any(isnan(colorRange))
    caxis(ax,colorRange);
  end
end


%% projection

% if there is already a stored projection use this one
if isfield(opts,'projection') 
  projection = opts.projection;
  return;  
end

% type of projection - default is earea
projection.type = get_option(varargin,'projection','earea');

% check for antipodal symmetry
projection.antipodal = check_option(varargin,'antipodal') || check_option(v,'antipodal');

%% for S2Grid take the stored values 
if isa(v,'S2Grid')

  [minTheta, maxTheta, minRho, maxRho] = get(v,'bounds');
  
else % otherwise default is the entire sphere / half sphere
  
  minTheta = 0;
  maxTheta = pi / (1+projection.antipodal);
  minRho = 0;
  maxRho = 2*pi;
  
end

%% restrict to northern hemisphere if possible
if max(reshape(get(v,'theta'),[],1)) < pi/2 + 0.001 && ...
    isnumeric(maxTheta) && maxTheta > pi/2

  maxTheta = pi/2;
  
end

%% get values from direct options
minTheta = get_option(varargin,'minTheta',minTheta);
maxTheta = get_option(varargin,'maxTheta',maxTheta);
minRho   = get_option(varargin,'minRho',minRho);
maxRho   = get_option(varargin,'maxRho',maxRho);
    
%% get values from meta options
if check_option(varargin,'complete')
  minRho = 0; maxRho = 2*pi;
  minTheta = 0; maxTheta = pi;
end

if check_option(varargin,'north') && isnumeric(maxTheta) && maxTheta > pi/2
  maxTheta = pi/2;  
end

if check_option(varargin,'south') && isnumeric(maxTheta) && ...
    maxTheta > pi/2+0.001  
  minTheta = pi/2;
end

%% read default plot options
plotOptions = getpref('mtex','defaultPlotOptions');

projection.minTheta = minTheta;
projection.minRho = minRho;
projection.maxTheta = maxTheta;
projection.maxRho = maxRho;
projection.flipud = check_option([varargin plotOptions],'flipud');
projection.fliplr = check_option([varargin plotOptions],'fliplr');
projection.drho = get_option(varargin,'rotate',get_option(plotOptions,'rotate',0));
  
%% compute boundary box and offset

projection.offset = 0;
  
% go through all boundary points of the plot
dgrid = 1*degree;
dgrid = pi/round((pi)/dgrid);
  
if maxRho > minRho
  rho = minRho:dgrid:(maxRho-dgrid);
else
  rho = mod(minRho:dgrid:(maxRho+2*pi-dgrid),2*pi);
end
if maxRho ~= 2*pi, rho(1) = [];end
  
if isnumeric(maxTheta)
  
  if maxTheta > pi/2
    theta = pi/2;
  else
    theta = maxTheta;
  end
else
  theta = maxTheta(rho);
end

% project the,
[x,y] = project( [sph2vec(0,rho) sph2vec(theta,rho)],projection);

% set offset
if isnumeric(maxTheta) && maxTheta > pi/2+1e-6 && ...
    minTheta < pi/2+1e-6 && ~strcmp(projection.type,'plain')

  % this is only needed if two hemispheres have to be plotted
  projection.offset = max(x)-min(x);
  
end

% set bounding box
projection.bounds = [min(x(:)),min(y(:)),max(x(:))+projection.offset,max(y(:))];

% set bounds to axes
set(ax,'XLim',[projection.bounds(1)-1e-4,projection.bounds(3)+1e-4]);
set(ax,'YLim',[projection.bounds(2)-1e-4,projection.bounds(4)+1e-4]);


%% store data
setappdata(ax,'projection',projection)
