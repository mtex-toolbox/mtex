function d = dot_outer(v1,v2,varargin)
% outer dot product
%
% Input
%  v1, v2 - @vector3d
%
% Output
%  d - double

% if second argument is Miller call corresponding method
if isa(v2,'Miller')
  d = dot_outer(v2,v1,varargin{:}).'; % TODO: check this!!!!
  return
end

if ~isempty(v1) && ~isempty(v2) 
      
  d = v1.x(:) * v2.x(:).' + v1.y(:) * v2.y(:).' + v1.z(:) * v2.z(:).';

  if check_option(varargin,'antipodal') || v1.antipodal || v2.antipodal
    d = abs(d);
  end
  
else  
  d  = [];  
end
