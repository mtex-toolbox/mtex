function criterion = gbc_angle(q,CS,Dl,Dr,threshold,varargin)
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

d = angle(orientation(q(Dl),CS),orientation(q(Dr),CS));

if isscalar(threshold)

  criterion = d < threshold;

else
  
  criterion = 0.5 * ((d < threshold(1)) + (d < threshold(2)));
  
end
