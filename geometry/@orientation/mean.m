function [o lambda eigv kappa q]  = mean(o,varargin)
% returns mean, kappas and sorted q of crystal symmetry euqal quaternions 
%
%% Syntax
% [o kappa v q q_std]  = mean(o,varargin)
%
%% Input
%  o        - list of @orientation
%
%% Options
%  weights  - list of weights
%
%% Output
%  mean   - mean orientation
%  lambda - singular values
%  eigv   - singular orientations
%  kappa  - form parameters of bingham distribution
%  q      - quaternions of fundamental region
%
%% See also
% BinghamODF

if numel(o) == 1 
  
  if nargout > 1
    eigv = quaternion(eye(4));
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
  [q,omega] = project2FundamentalRegion(q,o.CS,o.SS,old_mean);
  [q_mean lambda eigv] = mean(q,varargin{:});
  iter = iter + 1;
end

o.rotation = rotation(q_mean);

lambda = diag(lambda);

if nargout > 3
  kappa = evalkappa(lambda,varargin{:});
end


