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

T = qq(q,varargin{:});
[V lambda ] = eigs(T);
q.a = V(1,1);
q.b = V(2,1);
q.c = V(3,1);
q.d = V(4,1);
