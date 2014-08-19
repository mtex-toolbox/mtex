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

function [B,C] = Mesh_DL23_Range2(A,n1,n2)

    alphaAng = A; r=tan(alphaAng);
    phinum = n1; thetanum = n2;
    
    B = zeros(phinum,1); C = zeros(thetanum,phinum,1);
    
    thetavar1 = acos((2+sqrt(6*(tan(alphaAng))^2 - 2))/(6*tan(alphaAng)));

    phivar1 = 0; phivar2 = acos(cot(thetavar1)); 
    phivar3 = pi/2 - phivar2; phivar4 = pi/2;

    frac1 = (floor((phinum - 4)*(phivar2 - phivar1)/(phivar4 - phivar1)));
    frac2 = (floor((phinum - 4)*(phivar3 - phivar2)/(phivar4 - phivar1)));
    frac3 = phinum - 4 - frac1 - frac2;
    tempphi3 = linspace(phivar1,phivar2,(frac1 + 2)); 
    tempphi4 = linspace(phivar2,phivar3,(frac2 + 2)); 
    tempphi4(1) = [];
    tempphi5 = linspace(phivar3,phivar4,(frac3 + 2));
    tempphi5(1) = [];
    tempphi = [tempphi3 tempphi4 tempphi5];
    B(:,1) = tempphi;
    
    phicount = 1;
    for iphi = 1:phinum
        phi = tempphi(iphi);
        if (phi < phivar2)
            theta1 = 0;theta2 = acot(cos(phi));
            temptheta = linspace(theta1,theta2,thetanum);
            C(:,phicount,1) = temptheta;
        elseif(phi >= phivar2 && phi < phivar3)
            tempvar1 = cos(phi) + sin(phi);
            tempvar2 = (1 + tempvar1*sqrt(r^2 + (r^2)*(tempvar1)^2 -1))/(r*(1+tempvar1^2));
            theta1 = 0; theta2 = acos(tempvar2);
            temptheta = linspace(theta1,theta2,thetanum);
            C(:,phicount,1) = temptheta;
        elseif(phi >= phivar3)
            theta1 = 0;theta2 = acot(sin(phi));
            temptheta = linspace(theta1,theta2,thetanum);
            C(:,phicount,1) = temptheta;
        end
        phicount=phicount+1;
    end