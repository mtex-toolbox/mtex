function d = dot_outer(v1,v2)
% outer dot product
%% Input
%  v1, v2 - @vector3d
%% Output
%  @vector3d 

if ~isempty(v1) && ~isempty(v2) 
			
	d = reshape(v1.x,[],1) * reshape(v2.x,1,[]) + ...
		reshape(v1.y,[],1) * reshape(v2.y,1,[]) + ...
		reshape(v1.z,[],1) * reshape(v2.z,1,[]);

  % eliminate wrong values
  d(d>1) = 1;
  d(d<-1) = -1;
  
	d = reshape(d,[numel(v1),numel(v2)]);
else	
	d  = [];	
end
