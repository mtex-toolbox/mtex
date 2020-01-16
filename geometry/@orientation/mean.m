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
%  q      - crystallographic equivalent @quaternion projected to fundamental region
%  lambda - principle moments of inertia
%  V      - principle axes of inertia (@orientation)
%
% See also
% BinghamODF

if isempty(o)
  
  o.a = NaN; o.b = NaN; o.c = NaN; o.d = NaN; o.i = false;
  if nargout > 1, q = quaternion.nan;end
  if nargout > 2, lambda = zeros(4); end
  if nargout > 3, eigv = eye(4); end
  return
  
elseif length(o) == 1 
  
  if nargout > 1
    eigv = eye(4);
    q = quaternion(o);
  end
  return;
end

% first approximation
q_mean = get_option(varargin,'q0',quaternion(o,find(~isnan(o.a),1)));
q = quaternion(o);

if ~check_option(varargin,'noSymmetry')
  
  % project around q_mean
  q = project2FundamentalRegion(q,o.CS,o.SS,q_mean);
  
  % compute mean without symmetry
  [q_mean, lambda, eigv] = mean(q,varargin{:});
  
  if max(angle(q,q_mean,'noSymmetry')) > 10*degree
    q = project2FundamentalRegion(q,o.CS,o.SS,q_mean);
    [q_mean, lambda, eigv] = mean(q,varargin{:});
  end

  if nargout > 1, q = project2FundamentalRegion(q,o.CS,o.SS,q_mean); end

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
