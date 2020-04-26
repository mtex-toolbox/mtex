function [m, o, lambda, eigv]  = mean(o,varargin)
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
%  o      - crystallographic equivalent @orientation projected to fundamental region
%  lambda - principle moments of inertia
%  V      - principle axes of inertia (@orientation)
%
% See also
% BinghamODF

if isempty(o)
  m = o;
  m.a = NaN; m.b = NaN; m.c = NaN; m.d = NaN; m.i = false;
  if nargout > 2, lambda = zeros(1,4); end
  if nargout > 3, eigv = eye(4); end
  return  
elseif length(o) == 1 
  m = o;
  if nargout > 1
    eigv = eye(4);
    lambda = [1,0,0,0];
  end
  return;
end

if check_option(varargin,'noSymmetry')
  
  [m, lambda, eigv] = mean@quaternion(o,varargin{:});
    
else
  
  s = size(o);

  % first approximation
  m = get_option(varargin,'q0');
  if isempty(m), m = o.subSet(find(~isnan(o.a),1)); end
  
  % project around q_mean
  o = project2FundamentalRegion(o,m);
  
  % compute mean without symmetry
  [m, lambda, eigv] = mean@quaternion(o,varargin{:});

  d = abs(quat_dot(o,m));
  if min(d(:)) < cos(10*degree)
    o = project2FundamentalRegion(o,m);
    [m, lambda, eigv] = mean@quaternion(o,varargin{:});
  end

  if nargout > 1, o = reshape(project2FundamentalRegion(o,m),s); end
 
end
m.i = false;
