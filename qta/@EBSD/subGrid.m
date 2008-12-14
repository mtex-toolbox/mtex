function ebsd = subGrid (obj, q, angle, varargin)
% subgrid of EBSD-Orienations as angled neigborhood of a quaternion
%% Syntax
%  EBSD = subGrid (ebsd,q,angle)
% 
%% Input
%  obj      - @EBSD
%  midpoint - @quaternion
%  angle    - angle arround midpoint
%
%% Output
%  ebsd     - extracted @EBSD
%
%% Options
%  complement - return complement of choosen orienations
% 
%% See also

ind = [];
for i=1:numel(obj)
  ind = [ind sum(find(obj.orientations(i),q,angle),1)];
end

if check_option(varargin,'complement'), ind = ~ind; end

ebsd = subsref(obj,substruct('()', {':',find(ind)}));
