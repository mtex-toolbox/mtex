function a = angle(v1,v2,varargin)
% angle between two vectors
%
% Syntax
%   omega = angle(v1,v2)
%   omega = angle(v1,v2,'antipodal')
%   omega = angle(v1,v2,N)
%
% Input
%  v1, v2 - @vector3d
%       N - @vector3d normal to plane
%
% Output
%  omega - double
%
% Options
%  antipodal  - include <VectorsAxes.html antipodal symmetry>

if nargin == 3 && isa(varargin{1},'vector3d')

  N = normalize(varargin{1});
  v1 = normalize(v1 - dot(v1,N,'noSymmetry') .* N);
  v2 = normalize(v2 - dot(v2,N,'noSymmetry') .* N);

  a  = angle(v1,v2);

  ind = dot(N,cross(v1,v2),'noSymmetry')<0;
  a(ind) = 2*pi - a(ind);

else

  a = dot(v1.normalize,v2.normalize,varargin{:});

  a = real(acos(a));

end
