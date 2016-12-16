function [qm,lambda, V] = mean(q,varargin)
% mean of a list of quaternions, principle axes and moments of inertia
%
% Input
%  q        - list of @quaternion
%
% Options
%  weights  - list of weights
%
% Output
%  mean     - mean orientation
%  lambda   - principle moments of inertia
%  V        - principle axes of inertia (@orientation)
%
% See also
% orientation/mean

T = qq(q,varargin{:});
[V, lambda] = eig(T);
l = diag(lambda);
pos = find(max(l)==l,1);
qm = quaternion(V(:,pos));

if check_option(varargin,'robust') && length(q)>4
  omega = angle(qm,q);
  id = omega < quantile(omega,0.8);
  varargin = delete_option(varargin,'robust');
  [qm,lambda, V] = mean(q.subSet(id),varargin{:});
  
end
