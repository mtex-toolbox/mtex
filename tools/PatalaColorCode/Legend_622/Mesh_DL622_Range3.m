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

function [B,C] = Mesh_DL622_Range3(A,n1,n2)

    alphaAng = A; phinum = n1; thetanum = n2;
    
    B = zeros(thetanum,1); C = zeros(phinum,thetanum,1);
    
    r=tan(alphaAng);

    
    theta1 = acos((2-sqrt(3))/r); theta2 = asin(1/r); theta3 = pi/2;
    frac1 = (floor((thetanum - 3)*(theta2 - theta1)/(theta3 - theta1)));
    frac2 = (thetanum - 3) - frac1;
    temptheta1 = linspace(theta1,theta2,(frac1 + 2)); 
    temptheta2 = linspace(theta2,theta3,(frac2 + 2)); 
    temptheta2(1) = []; temptheta = [temptheta1 temptheta2];
        
    B(:,1) = temptheta;
    
    thetacount = 1;
    
    for itheta = 1:thetanum
        theta = temptheta(itheta);
        if((theta >= theta1) && (theta <= theta2))
            phi1 = 0; phi2 = pi/6;
            phiarray= linspace(phi1,phi2,phinum);
            C(:,thetacount,1) = phiarray;
        else
            phi1 = acos(1/(r*sin(theta)));
            phi2 = asin(1/(r*sin(theta))) - pi/3;
            phiarray= linspace(phi1,phi2,phinum);
            C(:,thetacount,1) = phiarray;                
        end
        thetacount = thetacount + 1;
    
    end