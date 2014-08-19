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

function Plot_DL222_Range3(A, B, C, lw1)

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
    b = [d1' d2' d3'];bv = rodri2volpreserv(b); ba = areapreservingx(bv);
    S = colormap222(b);
    
    theta1 = acos(1/r); theta2 = asin(sqrt(2)/r);
    t1 = [r*sin(theta1)*cos(acos(1/(r*sin(theta1)))) r*sin(theta1)*sin(acos(1/(r*sin(theta1)))) r*cos(theta1)];
    t2 = [r*sin(theta1)*cos(asin(1/(r*sin(theta1)))) r*sin(theta1)*sin(asin(1/(r*sin(theta1)))) r*cos(theta1)];
    t3 = [1 1 r*cos(theta2)];
    temp1 = areapreservingz(rodri2volpreserv((t1+t2)./2)); 
    temp2 = areapreservingz(rodri2volpreserv((t2+t3)./2)); 
    temp3 = areapreservingz(rodri2volpreserv((t3+t1)./2));
    ba=[ba;temp1;temp2;temp3];
    tri = delaunay(ba(:,1),ba(:,2));
    ind1 = find(tri(:,1) == size(ba,1)-2 | tri(:,2) == size(ba,1)-2 | tri(:,3) == size(ba,1)-2);
    ind2 = find(tri(:,1) == size(ba,1)-1 | tri(:,2) == size(ba,1)-1 | tri(:,3) == size(ba,1)-1);
    ind3 = find(tri(:,1) == size(ba,1) | tri(:,2) == size(ba,1) | tri(:,3) == size(ba,1));
    ind = [ind1;ind2;ind3];tri(ind,:)=[]; ba(size(ba,1)-2:size(ba,1),:)=[];

    patch('Faces',tri,'Vertices',[ba(:,1) ba(:,2) zeros(size(ba,1),1)],...
        'FaceVertexCData',S,'FaceColor','interp','EdgeColor','none');

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     
% % %  Plot the boundaries for the section  % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

y = linspace(sqrt(r^2-2),1,100);z = ones(1,size(y,2));x = sqrt(r^2 - y.^2-1); ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
plot3(ptsa(:,1),ptsa(:,2),0*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
y = linspace(sqrt(r^2-2),1,100);x = ones(1,size(y,2));z = sqrt(r^2 - y.^2-1); ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv); 
plot3(ptsa(:,1),ptsa(:,2),0*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
x = linspace(sqrt(r^2-2),1,100);y = ones(1,size(x,2));z = sqrt(r^2 - x.^2-1); ptsv = rodri2volpreserv([x' y' z']);ptsa = areapreservingz(ptsv);
plot3(ptsa(:,1),ptsa(:,2),0*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);

end