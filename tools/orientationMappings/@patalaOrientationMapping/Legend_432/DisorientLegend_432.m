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

function DisorientLegend_432(Deg, n1, n2)

    %%% Input: 
    %%% Deg:    Misorientation angle $\omega$ (in degrees) in the fundamental
    %%%         zone
    %%% n1:     Number of grid points in the theta direction
    %%% n2:     Number of grid points in the phi direction

    maxk = sqrt(2) - 1; maxdeg = 2*atan(sqrt(6*maxk^2 - 4*maxk + 1)); deg1 = 2*atan(sqrt(2*(maxk^2)));

    %%% Typical suggested Values of n1, n2 and Deg
    %%% n1 = 150, n2=300
    %%% 0 < Deg < maxdeg*180/pi (maxdeg defined below)

%     addpath('Necessary_Functions'); addpath('Plot_Functions'); addpath('Mesh_Functions');


    %%% Create_Mesh_Pts: Give the values of theta and phi for grid points for a
    %%% particular "Deg"
    %%% A: 1 X 1 scalar = \frac{\omega}{2} in radians
    %%% B: (n1 X 1) are the grid points on the range of valid theta
    %%% C: (n2 X n2 X 1) are the grid points on phi for each theta in B
    [A, B, C] = Create_Mesh_Pts_432(Deg, n1, n2);



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% Start Plotting

    w = 1; hold all, grid on; 
%     w = 1; figure(w), hold all, grid on; 
    alphaAng = A(w);r = tan(alphaAng);

    %%%%% Draw the outer triangle (equivalent to the stereographic triangle)
    lw2 = 1;
    y = linspace(0,r/(sqrt(2)),100);z = y - y;x = sqrt(r^2 - y.^2); ptsv = rodri2volpreserv([x' y' z']);
    ptsa = areapreservingx(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);
    x = linspace(r/sqrt(3),r,100);y = sqrt((r^2 - x.^2)/2);z = y; ptsv = rodri2volpreserv([x' y' z']);
    ptsa = areapreservingx(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);
    x = linspace(r/sqrt(3),r/sqrt(2),100);y = x;z = sqrt(r^2 - 2*x.^2); ptsv = rodri2volpreserv([x' y' z']);    
    ptsa = areapreservingx(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),':','Color',[0 0 0],'LineWidth',lw2);


    % % There exist regions where the section that cuts the
    % % fundamental zone has different shapes. These cases are dealt
    % % below in four different cases
    lw1=1; %% LineWidth for the section within the fundamental zone
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if (alphaAng <= pi/8)
        Plot_DL432_Range1(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if((alphaAng > pi/8) && (alphaAng <= pi/6))
        Plot_DL432_Range2(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if((alphaAng > pi/6) && (alphaAng < deg1/2))    
        Plot_DL432_Range3(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    if((alphaAng >= deg1/2) && (alphaAng <= maxdeg/2)) 
        Plot_DL432_Range4(A, B, C, lw1);
    end
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

    %%%%%%%%%%%% Set Plot Options
    %%%%%%%%%%%% 1) Position, 2) axis limits 3) Title

    xlim = areapreservingx(rodri2volpreserv([tan(maxdeg/2)/sqrt(2) tan(maxdeg/2)/sqrt(2) 0]));
    axis([-0.01,(2.2/2)*xlim(1),-0.01,(2.2/2)*xlim(1)]);
    temp1 = areapreservingx(rodri2volpreserv([r/sqrt(2) r/sqrt(2) 0]));
    axis off;