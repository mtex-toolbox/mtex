function v = ones(varargin)
% vectors with all entries ones
%
% Syntax
%   v = ones              % a ones vector 
%   v = ones('antipodal') % a ones axis
%   v = ones(m,n)         % a m x n matric of ones vectors
%
% Input
%  m,n - double
%
% Output
%  v - @vector3d
%
% See also
% ones

s = varargin(cellfun(@isnumeric,varargin));
x = ones(s{:});
v = vector3d(x,x,x,varargin{:});

end
