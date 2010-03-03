function d = dot_outer(v1,v2,varargin)
% outer dot product
%% Input
%  v1, v2 - @vector3d
%% Output
%  @vector3d 

if ~isempty(v1) && ~isempty(v2) 
			
	d = v1.x(:) * v2.x(:).' + v1.y(:) * v2.y(:).' + v1.z(:) * v2.z(:).';

  % eliminate wrong values
  d(d>1) = 1;
  d(d<-1) = -1;
  
  if check_option(varargin,'antipodal'), d = abs(d);end
  
else	
	d  = [];	
end
