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

function [B,C] = Mesh_DL422_Range4(A,n1,n2)

    alphaAng = A; thetacount = 1; phinum = n1; thetanum = n2;
    
    B = zeros(thetanum,1); C = zeros(phinum,thetanum,1);
    
    r=tan(alphaAng);
    theta1 = acos((tan(pi/8))/r); theta2 = asin((sqrt(1+(tan(pi/8))^2))/r);
    temptheta = linspace(theta1,theta2,thetanum);
    B(:,1) = temptheta;
    
    
    for itheta = 1:thetanum
        theta = temptheta(itheta);
        phi1 = acos(1/(r*sin(theta))); 
        phi2 = asin(1/(r*sin(theta)))-pi/4;
        phiarray = linspace(phi1,phi2,phinum);
        C(:,thetacount,1) = phiarray;
        thetacount=thetacount+1;
    end