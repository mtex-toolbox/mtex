function v = accumarray(subs,v,varargin)
% accumarray for vector3d
%
% Syntax
%   v = accumarray(subs,v)   
%
% Input
%  subs - 
%  v - @vector3d 
%
% Output
%  v - @vector3d

if v.antipodal
  
  % find a reference vector for each class
  ref = accumarray(subs,1:length(v),[],@(x) x(1));
  v_ref = v.subSet(ref(subs));
  
  flip = 1 - 2*(dot(v,v_ref,'noAntipodal') < 0);
  
  v.x = accumarray(subs,v.x .* flip,varargin{:});
  v.y = accumarray(subs,v.y .* flip,varargin{:});
  v.z = accumarray(subs,v.z .* flip,varargin{:});
  
else  
  
  v.x = accumarray(subs,v.x,varargin{:});
  v.y = accumarray(subs,v.y,varargin{:});
  v.z = accumarray(subs,v.z,varargin{:});
  
end  

v.isNormalized = false;
