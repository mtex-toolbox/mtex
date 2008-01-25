function nebsd = rotate(ebsd,q)
% rotate EBSD data
%
%% Input
%  ebsd - @EBSD
%  q    - @quaternion
%
%% Output
%  rotated ebsd - @EBSD

nebsd = ebsd;

for i = 1:length(ebsd) 
  nebsd.orientations = q * nebsd(i).orientations;
end
