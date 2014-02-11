function extend = getPlotRegion(v,varargin)
% returns plotting region in polar coordiantes

% default values from the vectors to plot
[minTheta, maxTheta,minRho,maxRho] = v.sphericalRegion(varargin{:});

% get values from direct options
minTheta = get_option(varargin,'minTheta',minTheta);
maxTheta = get_option(varargin,'maxTheta',maxTheta);
minRho   = get_option(varargin,'minRho',minRho);
maxRho   = get_option(varargin,'maxRho',maxRho);

% restrict using meta options north, south, upper, lower
%if strcmpi('outofPlane',getMTEXpref('zAxisDirection'))
%  if check_option(varargin,'upper'), varargin = set_option(varargin,'north');end
%  if check_option(varargin,'lower'), varargin = set_option(varargin,'south');end
%else
%  if check_option(varargin,'upper'), varargin = set_option(varargin,'south');end
%  if check_option(varargin,'lower'), varargin = set_option(varargin,'north');end
%end


if check_option(varargin,'upper') && isnumeric(maxTheta) && maxTheta > pi/2
  maxTheta = pi/2;
end

if check_option(varargin,'lower') && isnumeric(maxTheta) && ...
    maxTheta > pi/2+0.001
  minTheta = pi/2;
end

% check for antipodal symmetry
if (check_option(varargin,'antipodal') || v.antipodal) &&...
    minTheta == 0 && isnumeric(maxTheta) && maxTheta > pi/2 && ~check_option(varargin,'complete')
  maxTheta = pi/2;
end

extend.minTheta = minTheta;
extend.maxTheta = maxTheta;
extend.minRho = minRho;
extend.maxRho = maxRho;
