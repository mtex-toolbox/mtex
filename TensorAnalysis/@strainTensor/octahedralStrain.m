function [oG, oE] = octahedralStrain(epsilon)
% the octahedral strains
%
% Syntax
%   [oG, oE] = octahedralStrain(E)
%
% Input
%  E -  @strainTensor
%
% Output
%  oG - octahedral shear strain
%  oE - octahedral 'normal' strain

[~,qe] = eig(epsilon);
qe = sqrt(1+2*qe)-1;
qe = flipud(qe);

%  octahedral shear strain
oG = 2/3 * sqrt((qe(1)-qe(2)).^2+ (qe(2)-qe(3)).^2 +(qe(3)-qe(1)).^2)

%  octahedral normal strain
oE = sum(qe)/3
end
