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

function rgb = colormap432(v)

v = rotation('axis',vector3d(1,1,1),'angle',120*degree) * v;

pts = reshape(double(v),[],3);

kmax = sqrt(2)-1;
theta = atan2(pts(:,3),pts(:,2));
t2ind2 = find(pts(:,1) > 1/3 & theta > atan((1-2*pts(:,1))./(pts(:,1))));

tempvar2 = pts(t2ind2,2).*(1-pts(t2ind2,1));
tempvar3 = pts(t2ind2,1).*(pts(t2ind2,2)+pts(t2ind2,3))./(tempvar2 + 1*(tempvar2 == 0));
pts(t2ind2,:) = [pts(t2ind2,1) tempvar3.*pts(t2ind2,2) tempvar3.*pts(t2ind2,3)];
g1 = rotvec2mat([1 0 0 -3*pi/8]);
pts = pts*g1;
pts = [pts(:,1) - kmax pts(:,2) pts(:,3)];

tempvar = (1 + pts(:,2).*tan(pi/8)./(pts(:,3) + 1*(pts(:,3)==0)));
pts = [pts(:,1) pts(:,2).*tempvar pts(:,3).*tempvar];

%%%%% Def Step 3 %%%%%
pts = [pts(:,1) pts(:,2)*cos(pi/8)/tan(pi/8) (pts(:,3) - pts(:,1)./cos(pi/8))];

%%%%% Def Step 4 %%%%%%
theta = atan2(-pts(:,1),pts(:,2));
pts = [pts(:,1).*(sin(theta) + abs(cos(theta))) ...
    pts(:,2).*(sin(theta) + abs(cos(theta))) pts(:,3)];

%%%% Def Step 5 %%%%%
theta = atan2(-pts(:,1),pts(:,2));rad = hypot(pts(:,2),pts(:,1));
pts = [-rad.*sin(2*theta) rad.*cos(2*theta) pts(:,3)];
kmax = (sqrt(2)-1);tempk = cos(pi/8)/tan(pi/8);
pts(:,1) = pts(:,1)/kmax;pts(:,2) = pts(:,2)/kmax;pts(:,3) = pts(:,3)*tempk;
g1 = rotvec2mat([0 0 1 -pi/6]);
pts = pts*g1;

% S= hsvconereg(pts);
initS = hsvconereg(pts);
g1 = rotvec2mat([0 1 0 pi]);
initS = initS*g1;initS=[initS(:,1)+1 initS(:,2) initS(:,3)+1];
rgb = [initS(:,2) initS(:,3) initS(:,1)];
ind1 = find(rgb > 1 & rgb - 1 <= eps); rgb(ind1) = 1;
ind2 = find(rgb < 0 & rgb >= -10*eps); rgb(ind2) = 0;

return

 
kmax = sqrt(2)-1;
theta = atan2(z,y);
t2ind2 = find(x > 1/3 & theta > atan((1-2*x)./x));

tempvar2 = y(t2ind2) .* (1-x(t2ind2));
tempvar3 = x(t2ind2).*(y(t2ind2)+z(t2ind2))./(tempvar2 + 1*(tempvar2 == 0));
y(t2ind2) = tempvar3.*y(t2ind2);
z(t2ind2) = tempvar3.*z(t2ind2)

%

g1 = rotvec2mat([1 0 0 -3*pi/8]);
pts = pts*g1;
pts = [pts(:,1) - kmax pts(:,2) pts(:,3)];

tempvar = (1 + pts(:,2).*tan(pi/8)./(pts(:,3) + 1*(pts(:,3)==0)));
pts = [pts(:,1) pts(:,2).*tempvar pts(:,3).*tempvar];

%%%%% Def Step 3 %%%%%
pts = [pts(:,1) pts(:,2)*cos(pi/8)/tan(pi/8) (pts(:,3) - pts(:,1)./cos(pi/8))];

%%%%% Def Step 4 %%%%%%
theta = atan2(-pts(:,1),pts(:,2));
pts = [pts(:,1).*(sin(theta) + abs(cos(theta))) ...
    pts(:,2).*(sin(theta) + abs(cos(theta))) pts(:,3)];

%%%% Def Step 5 %%%%%
theta = atan2(-pts(:,1),pts(:,2));rad = hypot(pts(:,2),pts(:,1));
pts = [-rad.*sin(2*theta) rad.*cos(2*theta) pts(:,3)];
kmax = (sqrt(2)-1);tempk = cos(pi/8)/tan(pi/8);
pts(:,1) = pts(:,1)/kmax;pts(:,2) = pts(:,2)/kmax;pts(:,3) = pts(:,3)*tempk;
g1 = rotvec2mat([0 0 1 -pi/6]);
pts = pts*g1;

% S= hsvconereg(pts);
initS = hsvconereg(pts);
g1 = rotvec2mat([0 1 0 pi]);
initS = initS*g1;initS=[initS(:,1)+1 initS(:,2) initS(:,3)+1];
S = [initS(:,2) initS(:,3) initS(:,1)];
ind1 = find(S > 1 & S - 1 <= eps); S(ind1) = 1;
ind2 = find(S < 0 & S >= -10*eps); S(ind2) = 0;
