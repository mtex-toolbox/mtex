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

function S=hsvsphere(pts)

sphcoords = polarcoord(pts);

r = sphcoords(:,1);  % rho = radius
theta = sphcoords(:,2); % theta = polar angle
rho = sphcoords(:,3); % rho = azimuthal angle
 
%%%% Map (-pi,pi) to (0,2*pi)
maxrho = 2*pi; rho = mod(rho,maxrho);
%%%% Map (0,2*pi) to (-2*pi/3, 4*pi/3)
rho = rho - 2*pi/3; 
rho = mod(rho,maxrho)./maxrho;
% % %%%% Map (0,2*pi) to (-2*pi/3, 4*pi/3)
% % rho = rho + pi/3;
% % rho = mod(rho,maxrho)./maxrho;

ind1 = find(theta(:) >= pi/2); ind2 = find(theta(:) < pi/2);
if(size(ind2,1)>0)
c(ind2,:) = hsv2rgb(min(1,[rho(ind2),(2*r(ind2)./(1+r(ind2))).* ...
    theta(ind2)./pi*2,0.5 + r(ind2)./2]));

end
if(size(ind1,1)>0)
vval = r(ind1).*(2-theta(ind1)./pi*2) + 0.5 - r(ind1)./2;
c(ind1,:)  = hsv2rgb(min(1,[rho(ind1) ,1-(1-r(ind1))./ ...
    (2*(vval) + 1*(vval == 0)), vval]));

end

S = reshape(c,[size(pts,1),3]);
S = 1-S;
ind = find(S > 1); S(ind) = 1;
ind1 = find(S < 0); S(ind1) = 0;