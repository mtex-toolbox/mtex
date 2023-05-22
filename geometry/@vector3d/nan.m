function v = nan(varargin)
% vectors with all entries nan
%
% Syntax
%   v = nan              % a nan vector 
%   v = nan('antipodal') % a nan axis
%   v = nan(m,n)         % a m x n matric of nan vectors
%
% Input
%  m,n - double
%
% Output
%  v - @vector3d
%
% See also
% nan

s = varargin(cellfun(@isnumeric,varargin));
x = nan(s{:});
v = vector3d(x,x,x,varargin{:});

end
