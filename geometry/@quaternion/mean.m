function [mean lambda] = mean(q,varargin)
% returns mean, kappas and sorted q of crystal symmetry euqal quaternions 
%
%% Input
%  q         - list of @quaternion
%  varargin  - list of weights
%

T = qq(q,varargin{:});
[V lambda] = eigs(T);
mean = quaternion(V(1,1),V(2,1),V(3,1),V(4,1));
