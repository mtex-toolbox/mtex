function varargout = extent(mg,ind)
% spatial bounds of a mapImage
%
% The four corners are enough - the grid is regular, so nothing lies outside
% them. A rotated grid still gives an axis aligned bounding box, as it does
% for an EBSD map.
%
% Syntax
%
%   [xmin, xmax, ymin, ymax] = extent(mg)
%   ext = extent(mg)
%   ext = extent(mg,ind)
%
% Input
%  mg  - @mapImage
%  ind - which components of the combined form to return
%
% Output
%  xmin xmax ymin ymax - bounds
%  ext                 - [xmin xmax ymin ymax zmin zmax], as for @EBSD
%
% See also
% mapImage EBSD/extent

sz = size(mg);

corners = mg.origin + [0 0 sz(1)-1 sz(1)-1].*mg.d1 + [0 sz(2)-1 0 sz(2)-1].*mg.d2;

out = {min(corners.x), max(corners.x), ...
       min(corners.y), max(corners.y), ...
       min(corners.z), max(corners.z)};

if nargout <= 1
  varargout{1} = [out{:}];
  if nargin == 2, varargout{1} = varargout{1}(ind); end
else
  varargout = out(1:nargout);
end

end
