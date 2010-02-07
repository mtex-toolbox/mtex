function a = angle(v1,v2,varargin)
% angle between two vectors
%% Input
%  v1, v2 - @vector3d
%
%% Output
%  angle  - double
%
%% Options
%  antipodal  - include [[AxialDirectional.html,antipodal symmetry]]

if check_option(varargin,'antipodal')
  a = abs(dot(v1./norm(v1),v2./norm(v2),varargin{:}));
else
  a = dot(v1./norm(v1),v2./norm(v2),varargin{:});
end

a = real(acos(a));
