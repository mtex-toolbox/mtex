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

function DisorientLegend_622(Deg, n1, n2)
    %%% Input: 
    %%% Deg:    Misorientation angle $\omega$ (in degrees) in the fundamental
    %%%         zone
    %%% n1:     Number of grid points in the theta direction
    %%% n2:     Number of grid points in the phi direction

    %%% Typical suggested Values of n1, n2 and Deg
    %%% n1 = 150, n2=300
    %%% 0 < Deg < maxdeg*180/pi (maxdeg defined below)
    %%%% Deg = 50;
    %%%% Deg=55; 
    %%%% Deg=(60 + deg1*180/pi)/2; 
    %%%% Deg=180*(maxdeg + deg1)/(2*pi); 

%     addpath('Necessary_Functions'); addpath('Plot_Functions'); addpath('Mesh_Functions');

    deg1 = atan(2-sqrt(3));
    deg2 = atan(1);
    deg3 = atan(sqrt(1+(tan(pi/12))^2));
    deg4 = atan(sqrt(1+(tan(pi/12))^2 + (2-sqrt(3))^2));

    %%% Create_Mesh_Pts: Give the values of theta and phi for grid points for a
    %%% particular "Deg"
    %%% A: 1 X 1 scalar = \frac{\omega}{2} in radians
    %%% B: (n1 X 1) are the grid points on the range of valid
    %%% theta
    %%% C: (n2 X n2 X 1) are the grid points on phi for each theta in B
    [A, B, C] = Create_Mesh_Pts_622(Deg, n1, n2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% Start Plotting

    w = 1; hold all, grid on; 
%     w = 1; figure(w), hold all, grid on; 
    alphaAng = A(w);r = tan(alphaAng);

    lw2 = 1;

    y = linspace(0,r*sin(pi/6),100);z = y - y;x = sqrt(r^2 - y.^2); 
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);
    x = linspace(0,r,100);y = x - x;z = sqrt(r^2 - x.^2); 
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);
    z = linspace(0,r,100);x = cos(pi/6)*sqrt(r^2 - z.^2); y=tan(pi/6)*x;
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv);
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);

    % % There exist regions where the section that cuts the
    % % fundamental zone has different shapes. These cases are dealt
    % % below in three different cases
    lw1=1; %% LineWidth for the section within the fundamental zone
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if (alphaAng <= deg1)
        Plot_DL622_Range1(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if(alphaAng>deg1 && alphaAng <= deg2)
        Plot_DL622_Range2(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if(alphaAng > deg2 && alphaAng <= deg3)
        Plot_DL622_Range3(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if(alphaAng > deg3 && alphaAng <= deg4)
        Plot_DL622_Range4(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    
    %%%%%%%%%%%% Set Plot Options
    %%%%%%%%%%%% 1) Position, 2) axis limits 3) Title
    temp1 = areapreservingz(rodri2volpreserv([0 r 0]));
    axis equal off; 
    tempvar1 = sqrt(1+(tan(pi/12))^2 + (2-sqrt(3))^2);
    axlims = areapreservingz(rodri2volpreserv([tempvar1 0 0]));
    xlim([-0.01 2*axlims(1)/2]);
    ylim([-0.01 2*axlims(1)]/2);