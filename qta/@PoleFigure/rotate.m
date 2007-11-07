function rpf = rotate(pf,q)
% rotates pole figures by a certain rotation
%
%% Syntax  
% rpf = rotate(pf,q)
% 
%% Input
%  pf - @PoleFigure
%  q  - @quaternion
%
%% Output
%  rpf - rotated @PoleFigure
%
%% See also
% euler2quat axis2quat Miller2quat hr2quat ODF/rotate

rpf = pf;
for ipf = 1:length(pf)
	rpf(ipf).r =  rotate(pf(ipf).r,q);
end
