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

function Plot_DL622_Range1(A, B, C, lw1)
    
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
    clear b bv ba;
    b = [d1' d2' d3'];bv = rodri2volpreserv(b); ba = areapreservingz(bv);

    S =colormap622(b);

    tri = delaunay(ba(:,1),ba(:,2));
    patch('Faces',tri,'Vertices',[ba(:,1) ba(:,2) -1*ones(size(ba,1),1)],...
        'FaceVertexCData',S,'FaceColor','interp','EdgeColor','none');shading interp;

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     
    % % % % %  Plot the boundaries for the section  % % % % % % % % % % % % % % % %
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    y = linspace(0,r*sin(pi/6),100);z = y - y;x = sqrt(r^2 - y.^2); 
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    x = linspace(0,r,100);y = x - x;z = sqrt(r^2 - x.^2); 
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    z = linspace(0,r,100);x = cos(pi/6)*sqrt(r^2 - z.^2); y=tan(pi/6)*x;
    ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv);
    plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
end