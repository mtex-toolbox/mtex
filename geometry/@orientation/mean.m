function [o kappa v q q_std]  = mean(o,varargin)
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
%  mean  - mean orientation
%  kappa - singular values
%  v     - singular orientations
%  q_std - standard deviation  
%
%% See also

if numel(o) == 1 
  
  if nargout > 1
    v = idquaternion;
    kappa = [1 0 0 0];
    q_std = 0;
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
  iter = iter + 1;
  old_mean = q_mean;  
  [q,omega] = project2FundamentalRegion(q,o.CS,o.SS,old_mean);
  q_std = sum(omega.^2) ./ (length(omega)-1);
  [q_mean kappa v] = mean(q,varargin{:});
end

o.rotation = rotation(q_mean);

