function h = quiver3(SO3VF,varargin)
% 3-dimensional quiver SO(3) vector field
%
% Syntax
%   quiver3(SO3VF)
%
% Options
%  normalized - normalize vectors
%  arrowSize  - arrow size
%  maxHeadSize - head size

% See also
% SO3VectorField/plot
%

if SO3VF.antipodal, ap = {'antipodal'}; else, ap = {}; end

% generate a new 3d projection of the orientation space
oP = newOrientationPlot(SO3VF.SRight,SO3VF.SLeft,ap{:},'project2FundamentalRegion',...
  varargin{:});

% generate the plotting grid
S3G = oP.makeGrid('resolution',10*degree,varargin{:},'noBoundary');

% get the base points of the arrows
[x1,y1,z1] = oP.project(S3G);

% compute the tangential vectors
vec = SO3VF.eval(S3G,varargin{:});

% project tangential vectors to 3d space
[x2,y2,z2] = oP.project(exp(S3G,normalize(vec)/100));

% scale to the correct length
h = optiondraw(quiver3(x1,y1,z1,x2-x1,y2-y1,z2-z1));


if nargout == 0, clear h; end

end
