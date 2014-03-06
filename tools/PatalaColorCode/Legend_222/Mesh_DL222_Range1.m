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

function [B,C] = Mesh_DL222_Range1(n1,n2)

    phinum = n1; thetanum = n2;
    
    B = zeros(thetanum,1); C = zeros(phinum,thetanum,1);
    
    theta1 = 0; theta2 = pi/2;
    temptheta = linspace(theta1,theta2,thetanum);
    B(:,1) = temptheta; 
    
    thetacount = 1;
    for itheta = 1:thetanum
        phi1=0; phi2=pi/2;
        phiarray = linspace(phi1,phi2,phinum);
        C(:,thetacount,1) = phiarray;
        thetacount = thetacount + 1;
    end