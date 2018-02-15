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

T = qq(q,varargin{:});
[V, lambda] = eig(T);
l = diag(lambda);
[~,pos] = max(l);
qm = quaternion(V(:,pos));

if check_option(varargin,'robust') && length(q)>4
  omega = angle(qm,q);
  id = omega < quantile(omega,0.8);
  if ~any(id), return; end
  varargin = delete_option(varargin,'robust');
  [qm,lambda, V] = mean(q.subSet(id),varargin{:});
  
end
