function d = dot_outer(v1,v2,varargin)
% outer dot product
%
% Input
%  v1, v2 - @vector3d
%
% Output
%  d - double of size length(v1) x length(v2)
%
% Options
%  antipodal - consider smallest angle, i.e., consider vectors as axes
%  ignoreAntipodal - antipodal flag in v1/v2 is ignored
%

if ~isempty(v1) && ~isempty(v2) 
      
  d = v1.x(:) * v2.x(:).' + v1.y(:) * v2.y(:).' + v1.z(:) * v2.z(:).';

  if (check_option(varargin,'antipodal') || v1.antipodal || v2.antipodal) ...
      && ~check_option(varargin,'noAntipodal')
    d = abs(d);
  end
  
else  
  d  = [];  
end
