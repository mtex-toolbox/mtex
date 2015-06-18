function [q,alpha] = splineSmoothing(q,alpha)
% smooth spatial orientation data
%
% Input
%  q     - @quaternion
%  alpha - smoothing parameter

% project to tangential space
tq = log(q);

tq1 = reshape(tq(:,1),size(q));
tq2 = reshape(tq(:,2),size(q));
tq3 = reshape(tq(:,3),size(q));

% perform smoothing
[tq,alpha] = smoothn({tq1,tq2,tq3},alpha,'robust');

% project back to orientation space
q = reshape(expquat([tq{:}]),size(q));
  
  
  
