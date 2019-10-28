function v = zeros(varargin)
% vectors with all entries zeros
%
% Syntax
%   v = zeros              % the zero vector 
%   v = zeros('antipodal') % the zero axis
%   v = zeros(m,n)         % a m x n matric of zero vectors
%
% Input
%  m,n - double
%
% Output
%  v - @vector3d
%
% See also
% zeros

x = zeros(varargin{:});
v = vector3d(x,x,x);

end
