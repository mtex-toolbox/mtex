function a = angle(v1,v2,varargin)
% angle between two vectors
%
% Syntax
%   omega = angle(v1,v2)
%   omega = angle(v1,v2,'antipodal')
%   omega = angle(v1,v2,'noSymmetry')
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
%  noSymmetry - ignore symmetry
%

if nargin == 3 && isa(varargin{1},'vector3d')

  N = normalize(varargin{1});
  v1 = normalize(v1 - dot(v1,N,'noSymmetry','noAntipodal') .* N);
  v2 = normalize(v2 - dot(v2,N,'noSymmetry','noAntipodal') .* N);

  a  = angle(v1,v2,'noAntipodal');

  ind = dot(N,cross(v1,v2),'noSymmetry','noAntipodal')<0;
  a(ind) = 2*pi - a(ind);
  if v1.antipodal || v2.antipodal || check_option(varargin,'antipodal')
    a = mod(a,pi);  
  end

else

  a = dot(v1,v2,varargin{:});
  if ~v1.isNormalized, a = a ./ norm(v1); end
  if ~v2.isNormalized, a = a ./ norm(v2); end

  a = real(acos(a));

end
