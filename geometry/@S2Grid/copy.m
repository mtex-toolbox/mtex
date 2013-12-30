function S2G = copy(S2G,condition)
% copy certain condition from grid
%
% Input
%  S2G    - @S2Grid
%  condition - logical | double | @vector3d
%
% Output
%  S2G    - @S2Grid
%
% See also
% S2Grid/copy

if isa(condition,'vector3d'), condition = find(S2G,condition); end
if isnumeric(condition), 
  inds = false(length(S2G),1);
  inds(condition) = true;
  condition = inds; 
end

S2G = delete(S2G,~condition);
