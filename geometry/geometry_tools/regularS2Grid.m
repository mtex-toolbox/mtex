function S2G = regularS2Grid(varargin)
%
% Syntax
%   regularS2Grid('points',[72 19])
%   regularS2Grid('resolution',[5*degree 2.5*degree])
%   regularS2Grid('theta',theta,'rho',rho)
%
% Options
%  points     - [nrho,ntheta] number of points to be generated
%  resolution - resolution in polar and azimthal direction
%  hemisphere - 'lower', 'uper', 'complete', 'sphere', 'identified'
%  theta      - theta angle
%  rho        - rho angle
%  minRho     - starting rho angle (default 0)
%  maxRho     - maximum rho angle (default 2*pi)
%  minTheta   - starting theta angle (default 0)
%  maxTheta   - maximum theta angle (default pi)
%
% Flags
%  antipodal  - include <VectorsAxes.html antipodal symmetry>
%  restrict2MinMax - restrict margins to min / max
%
% See also
% equispacedS2Grid plotS2Grid

% extract options
bounds = getPolarRange(varargin{:});

% set up polar angles
theta = get_option(varargin,'theta',linspace(bounds.VR{1:2},bounds.points(2)));
theta = S1Grid(theta,bounds.FR{1:2});

% set up azimuth angles
steps = (bounds.VR{4}-bounds.VR{3}) / bounds.points(1);
rho = get_option(varargin,'rho',bounds.VR{3} + steps*(0:bounds.points(1)-1));
rho = repmat(...
  S1Grid(rho,bounds.FR{3:4},...
  'PERIODIC'),1,GridLength(theta));

% set up grid
S2G = S2Grid(theta,rho,varargin{:});

end
