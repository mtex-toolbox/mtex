function [f1,f2,f3] = Kearns(odf_o)
% Calculate Kearns factor of a hexagonal material
% Input parameters
%   odf_o=Orientation Distribution function, centred along direction 1;
% Output parameters
%   f1=Kearns factor along x1
%   f2=Kearns factor along x2
%   f3=Kearns factor along x3
% Based on equations published by AJ Anderson et al., Met. Mat. Trans A 1999

% Defines S2Grid
S2G = regularS2Grid('resolution',5*degree);
[~, theta] = polar(S2G);

% Defines (0002) Miller
ref=Miller(0,0,1,odf_o.CS);

odf_t=odf_o;
pf=calcPoleFigure(odf_t,ref,S2G);  
I_theta = pf.allI{1};
I_norm=sum(I_theta.*sin(theta));

f1 = sum((I_theta .* sin(theta).^3 .* cos(theta).^2)) / I_norm;
f2 = sum((I_theta .* sin(theta).^3 .* sin(theta).^2)) / I_norm;
f3 = sum((I_theta .* sin(theta).^1 .* cos(theta).^2)) / I_norm;
end
