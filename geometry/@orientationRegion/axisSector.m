function sR = axisSector(oR,omega)
% computes the sector of rotational axes for orientations within region
%
% Syntax
%   sR = axisSector(oR)
%   sR = axisSector(oR,omgea)
%
% Input
%  oR - @orientationRegion
%  omega - angle

N = oR.N.axis;

% 
ind = oR.N.angle>pi-1e-3;
sR = sphericalRegion(N(ind));

if nargin == 2
     
  % the radius of the small circles to excluded
  alpha = min(1,cot(omega./2) .* tan((pi-oR.N(~ind).angle)./2));
  
  % restrict fundamental sector
  sR.N = [sR.N,N(~ind)];
  sR.alpha = [sR.alpha,-alpha];

  sR = sR.cleanUp;
  
end

end

