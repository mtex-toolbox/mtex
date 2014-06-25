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

function DisorientLegend_23(Deg, n1, n2)

    %%% Input: 
    %%% Deg:    Misorientation angle $\omega$ (in degrees) in the fundamental
    %%%         zone
    %%% n1:     Number of grid points in the phi direction
    %%% n2:     Number of grid points in the theta direction

    deg1=pi/6; deg2= atan(1/sqrt(2)); deg3=pi/4;

    %%% Typical suggested Values of n1, n2 and Deg
    %%% n1 = 300, n2=150
    %%% 0 < Deg < deg3*360/pi (maxdeg defined below)


    %%% Create_Mesh_Pts: Give the values of theta and phi for grid points for a
    %%% particular "Deg"
    %%% A: 1 X 1 scalar = \frac{\omega}{2} in radians
    %%% B: (n1 X 1) are the grid points on the range of valid phi
    %%% C: (n2 X n2 X 1) are the grid points on theta for each phi in B
    [A, B, C] = Create_Mesh_Pts_23(Deg, n1, n2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% Start Plotting
    
    w = 1;
    hold all;
    alphaAng = A(w);
    r = tan(alphaAng);
    
    %%%%% Draw the outer triangle (equivalent to the stereographic triangle)
    lw2=1;
    y = linspace(0,r/sqrt(2),100);x = y - y;z = sqrt(r^2 - y.^2); if(abs(max(imag(z))) < 1e-05); z = real(z); end
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);
    x = linspace(0,r/sqrt(2),100);y = x - x;z = sqrt(r^2 - x.^2); if(abs(max(imag(z))) < 1e-05); z = real(z); end
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);
    x = linspace(r/sqrt(2),r/sqrt(3),100);z = x ;y = sqrt(r^2 - x.^2 - z.^2); if(abs(max(imag(y))) < 1e-05); y = real(y); end
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);
    y = linspace(r/sqrt(2),r/sqrt(3),100);z = y ;x = sqrt(r^2 - y.^2 - z.^2); if(abs(max(imag(x))) < 1e-05); x = real(x); end
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);
    
    
    % % There exist regions where the section that cuts the
    % % fundamental zone has different shapes. These cases are dealt
    % % below in three different cases
    lw1=1; %% LineWidth for the section within the fundamental zone
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if (alphaAng <=deg1)
        Plot_DL23_Range1(A, B, C, lw1)
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if(alphaAng>deg1 && alphaAng <= deg2)
        Plot_DL23_Range2(A, B, C, lw1);    
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if(alphaAng > deg2 && alphaAng <= deg3)
        Plot_DL23_Range3(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    

    %%%%%%%%%%%% Set Plot Options
    %%%%%%%%%%%% 1) Position, 2) axis limits 3) Title
    axlims1 = areapreservingx(rodri2volpreserv([0 0 sqrt(2)]));
    xlim([-0.1 axlims1(2)/2]);ylim([-0.1 axlims1(2)/2]);zlim([-0.1 2]);