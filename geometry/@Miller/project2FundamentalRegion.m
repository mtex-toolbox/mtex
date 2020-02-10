function h = project2FundamentalRegion(h, varargin)
% projects vectors to the fundamental sector of the inverse pole figure
%
% Input
%  h  - @Miller
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%
% Output
%  h - @Miller

if nargin>1 && isa(varargin{1},'symmetry')
  h = project2FundamentalRegion@vector3d(h,varargin{:});
else
  h = project2FundamentalRegion@vector3d(h,h.CS,varargin{:});
end
