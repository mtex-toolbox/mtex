function [o, q, lambda, eigv]  = mean(o,varargin)
% mean of a list of orientations, principle axes and moments of inertia
%
% Syntax
%   [m, q, lambda, V] = mean(ori)
%   [m, q, lambda, V] = mean(ori,'robust')
%   [m, q, lambda, V] = mean(ori,'weights',weights)
%
% Input
%  ori      - list of @orientation
%
% Options
%  weights  - list of weights
%
% Output
%  m      - mean @orientation
%  lambda - principle moments of inertia
%  V      - principle axes of inertia (@orientation)
%  q      - crystallographic equivalent @quaternion projected to fundamental region
%
% See also
% BinghamODF

if length(o) == 1 
  
  if nargout > 1
    eigv = eye(4);
    q = quaternion(o);
  end
  return;
end

% first approximation
q_mean = get_option(varargin,'q0',quaternion(o,find(~isnan(o.a),1)));
old_mean = [];
q = quaternion(o);

if ~check_option(varargin,'noSymmetry')
  % iterate mean
  iter = 1;
  while iter < 5 && (isempty(old_mean) || (abs(dot(q_mean,old_mean))<0.999))
    old_mean = q_mean;
    q = project2FundamentalRegion(q,o.CS,old_mean);
    [q_mean, lambda, eigv] = mean(q,varargin{:});
    iter = iter + 1;
  end
else
  [q_mean, lambda, eigv] = mean@quaternion(o,varargin{:});
end

q = reshape(q,size(o));

o.a = q_mean.a;
o.b = q_mean.b;
o.c = q_mean.c;
o.d = q_mean.d;
o.i = false;

lambda = diag(lambda);
