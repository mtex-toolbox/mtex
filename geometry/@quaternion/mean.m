function [q lambda V] = mean(q,varargin)
% returns mean, kappas and sorted q of crystal symmetry euqal quaternions 
%
%% Input
%  q        - list of @quaternion
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
% orientation/mean

T = qq(q,varargin{:});
[V lambda ] = eig(T);
l = diag(lambda);
pos = find(max(l)==l,1);
q.a = V(1,pos);
q.b = V(2,pos);
q.c = V(3,pos);
q.d = V(4,pos);
