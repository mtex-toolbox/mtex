function [i,j] = xy2ind(ebsd,x,y)
% convert x,y coordinates into indeces of ebsd
%
% Syntax
%
%   ind = xy2ind(ebsd,x,y)
%   ebsd(ind)
%
%   [i,j] = ind = xy2ind(ebsd,x,y)
%   ebsd(i,j)
%
% Input
%  ebsd - @EBSDSquare
%  x,y  - spatial coordinates
%
% Output
%  ind  - index to @EBSDSquare
%  i,j  - indeces to @EBSDSquare
%

if nargin == 2
  y = x(:,2);
  x = x(:,1);
end

i = 1+round((y - ebsd.y(1))./ebsd.dy);
j = 1+round((x - ebsd.x(1))./ebsd.dx);

if nargout == 1, i = sub2ind(size(ebsd),i,j); end