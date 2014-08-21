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

function Plot_DL432_Range3(A, B, C, lw1)

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

    ba=[ba;[0 0];areapreservingx(rodri2volpreserv([r/sqrt(3) r/sqrt(3) r/sqrt(3)]))];
    tri = delaunay(ba(:,1),ba(:,2));
    ind1 = find(tri(:,1) == size(ba,1)-1 | tri(:,2) == size(ba,1)-1 | tri(:,3) == size(ba,1)-1);
    ind2 = find(tri(:,1) == size(ba,1) | tri(:,2) == size(ba,1) | tri(:,3) == size(ba,1));
    ind = [ind1;ind2];tri(ind,:)=[]; ba([size(ba,1)-1;size(ba,1)],:)=[];

    S =colormap432(b);

    patch('Faces',tri,'Vertices',[ba(:,1) ba(:,2) -1*ones(size(ba,1),1)],...
        'FaceVertexCData',S,'FaceColor','interp','EdgeColor','none');
    shading interp;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     
% % %  Plot the boundaries for the section  % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

    thetac = acos((2-sqrt(6*(tan(alphaAng))^2 -2))/(6*tan(alphaAng))); 
    thetaa = acos((1-sqrt(6*(tan(alphaAng))^2 -2))/(3*tan(alphaAng))); 
    thetad = (acos(-(((sqrt(2)-1)*(cot(alphaAng)))^2)))/2; 
    thetab = pi/2;
    phi3 = acos((sqrt(2)-1)/(tan(alphaAng)*sin(thetab)));

    y = linspace(r*sin(phi3),r/(sqrt(2)),100);z = y - y;x = sqrt(r^2 - y.^2);ptsv = rodri2volpreserv([x' y' z']);
    ptsa = areapreservingx(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1); 
    z = linspace(r*cos(thetac),r*cos(thetad),100); y = z; x = sqrt(r^2 - 2*(z.^2));ptsv = rodri2volpreserv([x' y' z']);
    ptsa = areapreservingx(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    z = linspace(r*cos(thetaa),r*cos(thetab),100); x = sqrt((r^2 - (z.^2))/2); y = x; ptsv = rodri2volpreserv([x' y' z']);
    ptsa = areapreservingx(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    z = linspace(r*cos(thetad),r*cos(thetab),100); x = (sqrt(2)-1)*ones(size(z)); y = sqrt(r^2 - x.^2 - z.^2);
    ptsv = rodri2volpreserv([x' y' z']);
    ptsa = areapreservingx(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    theta = linspace(thetac,thetaa,100); tempd3 = tan(alphaAng)*cos(theta); 
    phi = acos((((1-tempd3)+(sqrt(2*((tan(alphaAng))^2 - tempd3.^2)-(1-tempd3).^2)))/2)./(tan(alphaAng)*sin(theta)));
    z = r*cos(theta); x = r*sin(theta).*cos(phi); y = sqrt(r^2 - x.^2 - z.^2); 
    ptsv = rodri2volpreserv([x' y' z']);
    ptsa = areapreservingx(ptsv); plot3(ptsa(:,1),ptsa(:,2),2*ones(1,100),'-','Color',[0 0 0],'LineWidth',lw1);
    
    
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

end