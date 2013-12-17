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

function [B,C] = Mesh_DL23_Range1(n1,n2)

    phinum = n1; thetanum = n2;
    
    B = zeros(phinum,1); C = zeros(thetanum,phinum,1);
    
    
    frac1 = floor(phinum/2);
    frac2 = phinum - frac1;
    tempphi1 = linspace(0,pi/4,frac1); 
    tempphi2 = linspace(pi/4,pi/2,frac2 + 1); tempphi2(1) = []; 
    phiarray = [tempphi1 tempphi2];
    B(:,1)=phiarray;

    for iphi = 1:phinum
        phi=phiarray(iphi);
        if(phi < pi/4)
            temptheta = linspace(0,acot(cos(phi)),thetanum);
            C(:,iphi,1)=temptheta;
        else
            temptheta = linspace(0,acot(sin(phi)),thetanum);
            C(:,iphi,1)=temptheta;
        end
    end