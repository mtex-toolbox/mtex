function [mean lambda V] = mean(q,varargin)
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
mean = quaternion(V(1,1),V(2,1),V(3,1),V(4,1));
