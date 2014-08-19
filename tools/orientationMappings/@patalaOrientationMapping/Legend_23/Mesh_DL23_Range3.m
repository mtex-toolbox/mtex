% Copyright 2013 Oliver Johnson, Srikanth Patala
% 
% This file is part of MisorientationMaps.
% 
%     MisorientationMaps is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     MisorientationMaps is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with MisorientationMaps.  If not, see <http://www.gnu.org/licenses/>.

function [B,C] = Mesh_DL23_Range3(A,n1,n2)

    alphaAng = A; r=tan(alphaAng);
    phinum = n1; thetanum = n2;
    
    B = zeros(phinum,1); C = zeros(thetanum,phinum,1);
    
    phivar1 = 0; phivar2 = pi/2;

    tempphi = linspace(phivar1,phivar2,phinum);
    B(:,1) = tempphi;

    phicount = 1;
    for iphi = 1:phinum
        phi = tempphi(iphi);    
        tempvar1 = cos(phi) + sin(phi);
        tempvar2 = (1 + tempvar1*sqrt(r^2 + (r^2)*(tempvar1)^2 -1))/(r*(1+tempvar1^2));
        theta1 = 0; theta2 = acos(tempvar2);

        temptheta = linspace(theta1,theta2,thetanum);
        C(:,phicount,1) = temptheta;
        phicount=phicount+1;
    end