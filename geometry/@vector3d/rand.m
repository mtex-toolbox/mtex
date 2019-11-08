function v = rand( varargin )
% random directions or axes
%
% Syntax
%   v = rand              % a random unit vector 
%   v = rand('antipodal') % a random axis
%   v = rand(m,n)         % a m x n matric of random unit vectors
%
%   cs = crystlSymmetry('432');
%   sR = cs.fundamentalSector;
%   v = rand(v,sR) % a random unit vector inside a spherical region
%
% Input
%  m,n - double
%  sR - @sphericalRegion
%
% Output
%  v - @vector3d
%
% See also
% rand

sR = extractSphericalRegion(varargin{:});

lastNum = find(~cellfun(@isnumeric,[varargin,{{}}]),1);
s = [varargin{1:lastNum-1} 1 1];
n = prod(s);

if isempty(sR.N)
  N = n;
else
  N = ceil(100 + 1.5 * n /sR.volume);
end

theta = acos(2*(rand(N,1)-0.5));
rho   = 2*pi*rand(N,1);

v = vector3d('theta',theta,'rho',rho);

ind = find(sR.checkInside(v));
ind = ind(1:n);

v = reshape(v.subSet(ind),s);
v.antipodal = check_option(varargin,'antipodal');

end