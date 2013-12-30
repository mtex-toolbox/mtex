function [o lambda eigv kappa q]  = mean(o,varargin)
% mean of a list of orientations, principle axes and moments of inertia
%
%% Syntax
% [m lambda V kappa q]  = mean(o)
%
%% Input
%  o        - list of @orientation
%
%% Options
%  weights  - list of weights
%
%% Output
%  m      - mean @orientation
%  lambda - principle moments of inertia
%  V      - principle axes of inertia (@orientation)
%  kappa  - form parameters of bingham distribution
%  q      - crystallographic equivalent @quaternion projected to fundamental region
%
%% See also
% BinghamODF

if numel(o) == 1
  
  if nargout > 1
    eigv = eye(4);
    lambda = [1 0 0 0]';
    kappa = [Inf 0 0 0]';
    q = quaternion(o);
  end
  return;
end

% first approximation
q_mean = get_option(varargin,'q0',quaternion(o,1));
old_mean = [];
q = quaternion(o);

% iterate mean
iter = 1;
while iter < 5 && (isempty(old_mean) || (abs(dot(q_mean,old_mean))<0.999))
  old_mean = q_mean;
  [q,omega] = project2FundamentalRegion(q,o.CS,old_mean);
  [q_mean lambda eigv] = mean(q,varargin{:});
  iter = iter + 1;
end

o.rotation = rotation(q_mean);

lambda = diag(lambda);

if nargout > 3
  kappa = evalkappa(lambda,varargin{:});
end


