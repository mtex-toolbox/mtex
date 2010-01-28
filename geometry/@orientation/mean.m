function [o kappa v q q_std]  = mean(o,varargin)
% returns mean, kappas and sorted q of crystal symmetry euqal quaternions 
%
%% Input
%  o        - list of @orientation
%
%% Options
%  weights  - list of weights
%
%% Output
%  mean     - mean orientation
%  lambda   -
%  V        -
%
%% See also

if numel(o.i) == 1 
  
  if nargout > 1
    v = idquaternion;
    kappa = [1 0 0 0];
    q_std = 0;
  end
  return;
end

% first approximation
q_mean = get_option(varargin,'q0',o.quaternion(1));
old_mean = [];

% iterate mean 
iter = 1;
while iter < 5 && (isempty(old_mean) || (abs(dot(q_mean,old_mean))<0.999))
  iter = iter + 1;
  old_mean = q_mean;  
  [q,omega] = getFundamentalRegion(o,old_mean);
  q_std = sum(omega.^2) ./ (length(omega)-1);
  [q_mean kappa v] = mean(q,varargin{:});
end

o.quaternion = q_mean;
o.i = 1;
