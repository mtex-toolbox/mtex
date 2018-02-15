function varargout = scatter(o,varargin)
% plots orientations in 3d
%
% Syntax
%   scatter(ori)
%
% Input
%  ori - @orientation
%
% Options
%  axisAngle - axis angle projection
%  Rodrigues - rodrigues parameterization
%  Euler     - 3d Bunge Euler plot
%  points    - number of orientations to be plotted
%  center    - orientation center
%
% Flags
%  ignoreFundamentalRegion    - plot orientation as they are
%  project2FundamentalRegion  - project orientations to fundamentalRegion (default)
%  restrict2FundamentalRegion - ignore all orientations outside the fundamentalRegion
%
% See also
% vector3d/text orientation/plot

if o.antipodal, varargin = [varargin,'antipodal']; end

oP = newOrientationPlot(o.CS,o.SS,varargin{:});

[varargout{1:nargout}] = oP.plot(o,varargin{:});
