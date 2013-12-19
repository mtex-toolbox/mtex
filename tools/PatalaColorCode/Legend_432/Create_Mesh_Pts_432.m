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

function [A, B, C] = Create_Mesh_Pts_432(Deg, n1, n2)

    %%% Input: 
    %%% Deg:    Misorientation angle $\omega$ (in degrees) in the fundamental
    %%%         zone
    %%% n1:     Number of grid points in the theta direction
    %%% n2:     Number of grid points in the phi direction
    
    %%% Output: 
    %%% A: 1 X 1 scalar = \frac{\omega}{2} in radians
    %%% B: (n1 X 1) are the grid points on the range of valid
    %%% theta
    %%% C: (n2 X n2 X 1) are the grid points on phi for each theta in B
    
    %%% Typical suggested Values of n1, n2 and Deg
    %%% n1 = 150, n2=300
    %%% 0 < Deg < maxdeg*180/pi (maxdeg defined below)

    maxk = sqrt(2) - 1; maxdeg = 2*atan(sqrt(6*maxk^2 - 4*maxk + 1));
    deg1 = 2*atan(sqrt(2*(maxk^2)));


    A = Deg*pi/360; alphaAng=A;

% % % % % % There exist for regions where the section that cuts the
% fundamental zone and has four different shapes. These cases are dealt
% below with four different functions for each case
    
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    if(alphaAng <= pi/8)
        %%% Since the shape of the function is independent of A in this
        %%% range, A is not an input for this function
        [B,C] = Mesh_DL432_Range1(n1,n2);
    end
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


    if((alphaAng > pi/8) && (alphaAng <= pi/6))        
        [B,C] = Mesh_DL432_Range2(A, n1,n2);
    end   

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    if((alphaAng > pi/6) && (alphaAng < deg1/2))
        [B,C] = Mesh_DL432_Range3(A, n1,n2);
    end

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    if((alphaAng >= deg1/2) && (alphaAng <= maxdeg/2))
        [B,C] = Mesh_DL432_Range4(A, n1,n2);
    end

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
end