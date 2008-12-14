function ebsd = rotate(ebsd,q)
% rotate EBSD data
%
%% Input
%  ebsd - @EBSD
%  q    - @quaternion
%
%% Output
%  rotated ebsd - @EBSD

for i = 1:numel(ebsd) 
  ebsd.orientations(i) = q * ebsd.orientations(i);
end
