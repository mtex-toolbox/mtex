function M = matrix(varargin)
% converts vector3d to double
%
% Input
%  v - @vector3d
%
% Output
%  M - double matrix of size 3 x length(v)

if nargin > 1
  v = vertcat(varargin{:});
else
  v = varargin{1};
end

M = [v.x(:),v.y(:), v.z(:)].';
