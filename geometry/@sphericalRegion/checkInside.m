function inside = checkInside(sR,v,varargin)
% check for points to be inside the spherical region
%
% Syntax
%
%   inside = checkInside(sR,v)
%   inside = checkInside(sR,v,'noAntipodal')
%
% Input
%  sR - @sphericalRegion
%  v  - @vector3d
%
% Output
%  isInside - logical
%
% Options
%  noAntipodal - ignore antipodal symmetry
% 
  
% verify all conditions are satisfies
inside = true(size(v));
v = normalize(vector3d(v));
for i = 1:length(sR.N)
  inside = inside & (dot(subSet(sR.N,i),v,'noAntipodal') >= sR.alpha(i)-1e-4);
end

% for antipodal symmetry check also -v
if (sR.antipodal || v.antipodal || check_option(varargin,'antipodal')) && ...
    ~check_option(varargin,'noAntipodal')
    
  insideAnti = true(size(v));
  for i = 1:length(sR.N)
    insideAnti = insideAnti & (dot(subSet(sR.N,i),-v,'noAntipodal') >= sR.alpha(i)-1e-4);
  end
  
  inside = inside | insideAnti;
  
end

end
