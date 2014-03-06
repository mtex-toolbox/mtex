function v = randv( varargin )

if nargin < 2
  varargin = [varargin 1];
end

theta = acos(2*(rand(varargin{:})-0.5));
phi   = 2*pi*rand(varargin{:});

v = sph2vec(theta,phi);