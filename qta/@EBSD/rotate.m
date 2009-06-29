function ebsd = rotate(ebsd,q)
% rotate EBSD data
%
%% Input
%  ebsd - @EBSD
%  q    - @quaternion
%
%% Output
%  rotated ebsd - @EBSD

if isa(q,'double')
  q = axis2quat(zvector,q);
end

for i = 1:length(ebsd) 
  ebsd(i).orientations = q * ebsd(i).orientations;
  
  if rotaxis(q) == zvector    
    ebsd(i).xy = (rotz(rotangle(q)) * ebsd(i).xy.').';
  end
  
end

function A = rotz(omega)

A = [[cos(omega) sin(-omega)];[sin(omega) cos(omega)]];
