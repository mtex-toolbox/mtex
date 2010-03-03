function pf = rotate(pf,q)
% rotates pole figures by a certain rotation
%
%% Syntax  
% pf = rotate(pf,q)
% 
%% Input
%  pf - @PoleFigure
%  q  - @rotation
%
%% Output
%  pf - rotated @PoleFigure
%
%% See also
% euler2quat axis2quat Miller2quat hr2quat ODF/rotate

for ipf = 1:length(pf)
	pf(ipf).r =  rotate(pf(ipf).r,q);
end
