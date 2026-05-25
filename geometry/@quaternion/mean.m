function [qm, lambda, V] = mean(q,varargin)
% mean of a list of quaternions, principle axes and moments of inertia
%
% Syntax
%
%   [m, lambda, V] = mean(q)
%   [m, lambda, V] = mean(q,'robust')
%   [m, lambda, V] = mean(q,'weights',weights)
%
% Input
%  q        - list of @quaternion
%  weights  - list of weights
%
% Output
%  m      - mean orientation
%  lambda - principle moments of inertia
%  V      - principle axes of inertia (@quaternion)
%
% See also
% orientation/mean


qm = q;

if isempty(q) || all(isnan(q.a(:)))
  
  [qm.a,qm.b,qm.c,qm.d] = deal(nan,nan,nan,nan);
  lambda = [0 0 0 1];
  if nargout == 3, V = nan(4); end
  return
elseif isscalar(q)
  lambda = [0 0 0 1];
  if nargout == 3
    T = qq(q,varargin{:});
    [V, lambda] = eig(T);
    lambda = diag(lambda).';
  end
  return
end

% shall we apply the robust algorithm?
isRobust = check_option(varargin,'robust');
if isRobust, varargin = delete_option(varargin,'robust'); end

T = qq(q,varargin{:});
[V, lambda] = eig(T);
lambda = diag(lambda).';
[~,pos] = max(lambda);

qm.a = V(1,pos); qm.b = V(2,pos); qm.c = V(3,pos); qm.d = V(4,pos);
if isa(qm,'rotation'), qm.i = false; end
if nargout == 3
  V = quaternion(V(1,:),V(2,:),V(3,:),V(4,:));
end

if isRobust && length(q)>4
  omega = angle(qm,q,'noSymmetry');
  id = omega <= quantile(omega,0.8)*2.5;
  if all(id), return; end
  if nargout == 3
    [qm,lambda, V] = mean(q.subSet(id),varargin{:});
  else
    [qm,lambda] = mean(q.subSet(id),varargin{:});
  end
end
