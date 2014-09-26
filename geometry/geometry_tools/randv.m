function v = randv( varargin )

if nargin < 2
  varargin = [varargin 1];
end

theta = acos(2*(rand(varargin{:})-0.5));
rho   = 2*pi*rand(varargin{:});

v = vector3d('theta',theta,'rho',rho);
