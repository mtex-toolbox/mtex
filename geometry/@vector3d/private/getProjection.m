function [projection,extend] = getProjection(ax,v,varargin)

% get stored options
opts = getappdata(ax);
extend = opts.extend;

% if there is already a stored projection use this one
if isfield(opts,'projection') 
  projection = opts.projection;
  return;  
end

% type of projection - default is earea
projection.type = get_option(varargin,'projection','earea');

% check for antipodal symmetry
projection.antipodal = check_option(varargin,'antipodal') || check_option(v,'antipodal');

%% read default plot options
projection.xAxis = getpref('mtex','xAxisDirection');
projection.zAxis = getpref('mtex','zAxisDirection');


%% compute boundary box
minRho = extend.minRho;
maxRho = extend.maxRho;
minTheta = extend.minTheta;
maxTheta = extend.maxTheta;


% go through all boundary points of the plot
dgrid = 1*degree;
dgrid = pi/round((pi)/dgrid);
  
if maxRho > minRho
  rho = minRho:dgrid:maxRho;
else
  rho = mod(minRho:dgrid:maxRho+2*pi,2*pi);
end
  
if isnumeric(maxTheta)
  
  if strcmp(projection.type,'plain') || maxTheta < pi/2
    theta = maxTheta;    
  else
    theta = pi/2;
  end
else
  theta = maxTheta(rho);
end

% project the,
[x,y] = project( [sph2vec(0,rho) sph2vec(theta,rho)],projection,extend);

% set bounding box
projection.bounds = [min(x(:)),min(y(:)),max(x(:)),max(y(:))];

% set bounds to axes
set(ax,'DataAspectRatio',[1 1 1],...
  'XLim',[projection.bounds(1)-1e-2,projection.bounds(3)+2e-2],...
  'YLim',[projection.bounds(2)-1e-2,projection.bounds(4)+2e-2]);

%% store data
setappdata(ax,'projection',projection)

%% set view point
setCamera(ax);

set(ax,'dataaspectratio',[1 1 1]);