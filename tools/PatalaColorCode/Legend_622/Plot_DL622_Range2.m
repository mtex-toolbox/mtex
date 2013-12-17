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

function Plot_DL622_Range2(A, B, C, lw1)

    % %     %%%% Optional Function Paramters
    % %     lw1=2; %% Line width for the section boundary

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     
    % % %  Create MeshPoints (RV parameterization) (d1, d2, d3) given % % % % %
    % % %  the values of $\alpha$, $\theta$, $\phi$ of the grid points  % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

    pts2 = size(B,1); pts1 = size(C,1);
    d3 = zeros(1,1000000); d2 = zeros(1,1000000); d1 = zeros(1,1000000);
    w=1; alphaAng = A(w); r = tan(alphaAng);
    
    
    count1 = 1;
    for k=1:pts1
        for l=1:pts2
            d3(count1) = tan(A(w))*cos(B(l,w)); 
            d2(count1) = tan(A(w))*sin(B(l,w))*sin(C(k,l,w)); 
            d1(count1) = tan(A(w))*sin(B(l,w))*cos(C(k,l,w)); 
            count1 = count1 + 1;
        end
    end
    totpts = count1 - 1; d3((totpts + 1):1:1000000)=[]; d2((totpts + 1):1:1000000)=[]; d1((totpts + 1):1:1000000)=[];
    

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     
    % % %  Convert RV points to vol-preserving and then project % % % % % % % %
    % % % using  area preserving projection and map these points to % % % % % %
    % % % % colors and plot them for legend % % % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

    clear tmpA b tmpq1 tmpq2 tmpq3 tmpc tmpz bv ba S;
    tmpA = [d1' d2' d3'];b = unique(tmpA,'rows');
    bv = rodri2volpreserv(b); ba = areapreservingz(bv); S = colormap622(b);

    theta1 = acos((2-sqrt(3))/r); theta2 = pi/2;
    t1 = [r*sin(theta1)*cos(0) r*sin(theta1)*sin(0) r*cos(theta1)];
    t2 = [r*sin(theta1)*cos(pi/6) r*sin(theta1)*sin(pi/6) r*cos(theta1)];
    temp1 = areapreservingz(rodri2volpreserv((t1+t2)./2)); 
    ba=[ba;temp1];
    tri = delaunay(ba(:,1),ba(:,2));
    ind1 = find(tri(:,1) == size(ba,1) | tri(:,2) == size(ba,1) | tri(:,3) == size(ba,1));
    ind = [ind1];tri(ind,:)=[]; ba(size(ba,1),:)=[];
    %         trimesh(tri,ba(:,1),ba(:,2),zeros(size(ba,1),1));
    patch('Faces',tri,'Vertices',[ba(:,1) ba(:,2) zeros(size(ba,1),1)],...
        'FaceVertexCData',S,'FaceColor','interp','EdgeColor','none');


    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     
    % % % % %  Plot the boundaries for the section  % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


    y = linspace(0,r*sin(pi/6),100);z = y - y;x = sqrt(r^2 - y.^2); 
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    z = linspace(2-sqrt(3),0,100);y = x - x;x = sqrt(r^2 - z.^2); 
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    z = linspace(2-sqrt(3),0,100);x = cos(pi/6)*sqrt(r^2 - z.^2); y=tan(pi/6)*x;
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv);
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    y = linspace(0,sqrt(r^2 - (2-sqrt(3))^2)*sin(pi/6),100);z = (2-sqrt(3))*ones(1,size(y,2));
    x = sqrt(r^2 - y.^2 - z.^2); 
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);



end