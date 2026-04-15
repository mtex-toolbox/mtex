function h = quiver3(tV,varargin)
% 3-dimensional quiver of tangent vectors
%
% Syntax
%   quiver3(tV)
%
% Input
%  tV - @SOTangentVector
%
% Options
%  normalized - normalize vectors
%  linewidth  - with of the arrow
%  arrowSize  - arrow size
%  maxHeadSize - head size
%
% See also
% SO3VectorField/quiver3
%

% generate a new 3d projection of the orientation space
oP = newOrientationPlot(tV.hiddenCS,tV.hiddenSS,'project2FundamentalRegion',...
  varargin{:});

% get the base points of the arrows
[x1,y1,z1] = oP.project(tV.rot);

if check_option(varargin,'normalize')
  tV = normalize(tV);
else
  tV = tV ./ max(norm(tV(:)));
end

% project tangential vectors to 3d space
[x2,y2,z2] = oP.project(exp(tV));

wasHold = ishold(gca); hold(gca,'on');

% scale to the correct length
h = optiondraw(quiver3(x1,y1,z1,x2-x1,y2-y1,z2-z1),varargin{:});

if ~wasHold, hold(gca,'off'); end

if nargout == 0, clear h; end

end
