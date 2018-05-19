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

function S=colormap222(v)

pts = reshape(double(v),[],3);

k1 = sqrt(3)*max(pts,[],2)./(sum(pts,2) + 1*(sum(pts,2) == 0));
pts = [k1.*pts(:,1) k1.*pts(:,2) k1.*pts(:,3)];

%%% Rotate Prism %%%%%%%%
g1 = rotvec2mat([1,1,1,pi/4]);g2 = rotvec2mat([-1,1,0,acos(1/sqrt(3))]);
g3 = rotvec2mat([0,0,1,-pi/3]);pts = pts*g1*g2*g3;pts(:,3)=pts(:,3)-1;

%%%%%% Prism --> Cone %%%%%%%%%%%
phi=atan2(pts(:,2),pts(:,1));maxphi = 2*pi; phi = mod(phi,maxphi);
rfin = hypot(pts(:,1),pts(:,2)).*sin(pi/6+mod(phi,2*pi/3))./(sin(pi/6));
pts = [sqrt(1/2).*rfin.*cos(phi) sqrt(1/2).*rfin.*sin(phi) pts(:,3)];

%%%%%% Cone --> Hemisphere %%%%%%
r = sqrt(pts(:,1).^2 + pts(:,2).^2 + pts(:,3).^2);
rad = sqrt(pts(:,1).^2 + pts(:,2).^2);

pts = [pts(:,1).*(rad - pts(:,3))./(r+1*(r==0)) ...
    pts(:,2).*(rad - pts(:,3))./(r+1*(r==0)) ...
    pts(:,3).*(rad - pts(:,3))./(r+1*(r==0))];

%%%%% Hemisphere --> Sphere

phi1 = atan2(pts(:,2),pts(:,1));phi1 = mod(phi1,2*pi);
ind1=find(phi1 < 2*pi/3 & phi1 > 0*pi/3);ind2=find(phi1 < 4*pi/3 & phi1 > 2*pi/3);
ind3=find(phi1 < 6*pi/3 & phi1 > 4*pi/3);ind = [ind1;ind2;ind3];

g4 = rotvec2mat([0,0,1,pi/3]);g5 = rotvec2mat([0,0,1,pi]);g6 = rotvec2mat([0,0,1,5*pi/3]);
pts(ind1,:) = pts(ind1,:)*g4;pts(ind2,:) = pts(ind2,:)*g5;pts(ind3,:) = pts(ind3,:)*g6;

phi2 = atan2(pts(ind,2),pts(ind,1));rad1 = hypot(pts(ind,2),pts(ind,1));
pts(ind,:) = [rad1.*cos(3*phi2/2) rad1.*sin(3*phi2/2) pts(ind,3)];

mult = 1 + 1;
phi4 = atan2(pts(ind,1),-pts(ind,3));rad4 = hypot(pts(ind,1),pts(ind,3));
pts(ind,:) = [rad4.*sin(mult*phi4) pts(ind,2) rad4.*-cos(mult*phi4)];

phi3 = atan2(pts(ind,2),pts(ind,1));rad3 = hypot(pts(ind,2),pts(ind,1));
pts(ind,:) = [rad3.*cos(2*phi3/3) rad3.*sin(2*phi3/3) pts(ind,3)];

pts(ind1,:) = pts(ind1,:)*g4';pts(ind2,:) = pts(ind2,:)*g5';pts(ind3,:) = pts(ind3,:)*g6';

g1 = rotvec2mat([0,0,1,pi/3]);
pts=pts*g1;

S = hsvsphere(pts);
