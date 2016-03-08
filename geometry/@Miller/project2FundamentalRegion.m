function h = project2FundamentalRegion(h, varargin)
% projects vectors to the fundamental sector of the inverse pole figure
%
% Input
%  h  - @Miller
%
% Options
%  antipodal  - include <AxialDirectional.html antipodal symmetry>
%
% Output
%  h - @Miller

h = Miller(project2FundamentalRegion@vector3d(h,h.CS,varargin{:}),h.CS);
