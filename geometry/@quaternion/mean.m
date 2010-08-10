function [q lambda V] = mean(q,varargin)
% mean of a list of quaternions, principle axes and moments of inertia
%
%% Input
%  q        - list of @quaternion
%
%% Options
%  weights  - list of weights
%
%% Output
%  mean     - mean orientation
%  lambda   - principle moments of inertia
%  V        - principle axes of inertia (@orientation)
%
%% See also
% orientation/mean

T = qq(q,varargin{:});
[V lambda ] = eig(T);
l = diag(lambda);
pos = find(max(l)==l,1);
q.a = V(1,pos);
q.b = V(2,pos);
q.c = V(3,pos);
q.d = V(4,pos);
