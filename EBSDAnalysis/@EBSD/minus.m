function ebsd = minus(ebsd,xy)
% shift ebsd in x/y direction
%
% Syntax
%
%   % shift in x direction
%   ebsd = ebsd + [100,0] 
%
% Input
%  ebsd - @EBSD
%  xy - x and y coordinates of the shift
%
% Output
%  ebsd - @EBSD

ebsd = ebsd + (-xy);