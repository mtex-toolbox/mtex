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

if isempty(q)
  [qm.a,qm.b,qm.c,qm.d] = deal(nan,nan,nan,nan);
  lambda = diag([0 0 0 1]);
  if nargout == 3, V = nan(4); end
  return
elseif length(q) == 1
  lambda = diag([0 0 0 1]);
  if nargout == 3
    T = qq(q,varargin{:});
    [V, lambda] = eig(T);
  end
  return
end

T = qq(q,varargin{:});
[V, lambda] = eig(T);
l = diag(lambda);
[~,pos] = max(l);

[qm.a,qm.b,qm.c,qm.d] = deal(V(1,pos),V(2,pos),V(3,pos),V(4,pos));

if check_option(varargin,'robust') && length(q)>4
  omega = angle(qm,q);
  id = omega < quantile(omega,0.8)*(1+1e-5);
  if ~any(id), return; end
  varargin = delete_option(varargin,'robust');
  if nargout == 3
    [qm,lambda, V] = mean(q.subSet(id),varargin{:});
  else
    [qm,lambda] = mean(q.subSet(id),varargin{:});
  end
end
