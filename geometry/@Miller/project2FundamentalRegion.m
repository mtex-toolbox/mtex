function varargout = project2FundamentalRegion(h, varargin)
% projects vectors to the fundamental sector of the inverse pole figure
%
% Input
%  h  - @Miller
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%
% Output
%  h   - @Miller
%  sym - @rotation the symmetry element used for the projection
%

if nargin>1 && isa(varargin{1},'symmetry')
  [varargout{1:nargout}] = project2FundamentalRegion@vector3d(h,varargin{:});
else
  [varargout{1:nargout}] = project2FundamentalRegion@vector3d(h,h.CS,varargin{:});
end
