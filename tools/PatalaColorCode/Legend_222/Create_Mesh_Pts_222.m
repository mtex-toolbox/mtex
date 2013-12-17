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

function [A, B, C] = Create_Mesh_Pts_222(Deg, n1, n2)

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
    maxdeg=60/180*pi;

    A = Deg*pi/360; alphaAng=A;

    % % % % % % There exist for regions where the section that cuts the
    % fundamental zone and has three different shapes. These cases are dealt
    % below with three different functions for each case

    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    if(alphaAng <= pi/4)
        %%% Since the shape of the function is independent of A in this
        %%% range, A is not an input for this function
        [B,C] = Mesh_DL222_Range1(n1,n2);
    end
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    if(alphaAng > pi/4 && alphaAng <= atan(sqrt(2)))
        [B,C] = Mesh_DL222_Range2(A, n1,n2);
    end   

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    if(alphaAng > atan(sqrt(2)) && alphaAng <= pi/3)
        [B,C] = Mesh_DL222_Range3(A, n1,n2);
    end

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
end