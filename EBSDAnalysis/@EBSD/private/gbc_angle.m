function criterion = gbc_angle(q,cs,Dl,Dr,threshold,varargin)
%
% Input
%  q  - quaternion
%  CS - @crystalSymmetry
%  Dl, Dr - left / right indices of boundary orientations
%  threshold - [low angle threshold, high angle threshold]
% 
% Output
%  d - 0 no boundary, 0.5 low angle boundary, 1 high angle boundary
%

mori = itimes(q(Dl),q(Dr),1);
d = max(abs(dot_outer(mori,cs.properGroup.rot)),[],2);
  
criterion = mean(d > cos(threshold/2),2);



