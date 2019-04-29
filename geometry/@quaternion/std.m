function sigma = std(q,varargin)
% mean angular deviation
%
% Syntax
%
%   [m, lambda, V] = std(q)
%   [m, lambda, V] = std(q,'robust')
%   [m, lambda, V] = std(q,'weights',weights)
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

qm = mean(q,varargin{:});

sigma = sqrt(mean(angle(qm,q).^2));