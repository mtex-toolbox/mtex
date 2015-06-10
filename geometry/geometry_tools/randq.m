function q = randq(varargin)
% returns random quaternions

if nargin < 2
  varargin = [varargin 1];
end

alpha = 2*pi*rand(varargin{:});
beta  = acos(2*(rand(varargin{:})-0.5));
gamma = 2*pi*rand(varargin{:});

q = euler2quat(alpha,beta,gamma);
