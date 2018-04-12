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

function sphcoord = polarcoord(v)

%%%%% Cartesian to spherical coordinates
%%%%% v = n x 3 array of pts
%%%%% output is n x 3 array of spherical coordinates
%%%%% [r theta phi] 

r = sqrt(v(:,1).^2 + v(:,2).^2 + v(:,3).^2);
ind1 = find(r == 0);
ind2 = find(r ~= 0);

if(size(ind1,2) > 0)
theta(ind1)=0; phi(ind1)=0;
end

if(size(ind2,2) > 0)
    theta(ind2) = acos(v(ind2,3)./r(ind2));
    phi(ind2) = atan2(v(ind2,2),v(ind2,1));
end

sphcoord = [r theta' phi'];
end