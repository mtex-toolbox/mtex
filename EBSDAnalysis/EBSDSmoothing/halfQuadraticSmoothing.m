function [q,alpha] = halfQuadraticSmoothing(q,alpha)
% smooth spatial orientation data
%
% Input
%  q     - @quaternion
%  alpha - smoothing parameter

if nargin == 1 || isempty(alpha), alpha = 0.1; end

q = sign(q.a) .* q;

s = @(t,e) 1./(t.^2+e^2).^(1/2);
M = qSO3;

q = hq_inpainting_so(M,q,alpha,s,10^-1,10^-5,isnan(q.a));