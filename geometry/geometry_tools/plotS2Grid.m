function S2G = plotS2Grid(varargin)
%
% Syntax
%   plotS2Grid('resolution',[5*degree 2.5*degree])
%
% Options
%  resolution - resolution in polar and azimthal direction
%  hemisphere - 'lower', 'uper', 'complete', 'sphere', 'identified'
%  minRho     - starting rho angle (default 0)
%  maxRho     - maximum rho angle (default 2*pi)
%  minTheta   - starting theta angle (default 0)
%  maxTheta   - maximum theta angle (default pi)
%
% Flags
%  antipodal  - include <AxialDirectional.html antipodal symmetry>
%  restrict2MinMax - restrict margins to min / max
%
% See also
% equispacedS2Grid regularS2Grid


% extract options
bounds = getPolarRange(varargin{:});

% set up polar angles
theta = S1Grid(linspace(bounds.VR{1:2},bounds.points(2)),bounds.FR{1:2});

% set up azimuth angles
steps = (bounds.VR{4}-bounds.VR{3}) / bounds.points(1);
rho = repmat(...
  S1Grid(bounds.VR{3} + steps*(0:bounds.points(1)),bounds.FR{3:4}),...
  1,bounds.points(2));

S2G = S2Grid(theta,rho);

S2G = S2G.setOption('plot',true,'resolution',steps);

% TODO: extractoptions 'north','south','antipodal','lower','upper'

end
