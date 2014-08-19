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

function pts = changefundzone23(inpts)

tphi = atan2(inpts(:,2),inpts(:,1));
ind1 = find(tphi < pi/4);
ind2 = find(tphi >= pi/4);

g1 = rotvec2mat([1,1,1,-2*pi/3]);
if(size(ind1,2) > 0)
    pts(ind1,:) = inpts(ind1,:)*g1;
end
g2 = rotvec2mat([1,1,1,2*pi/3]);
if(size(ind2,2) > 0)
    pts(ind2,:) = inpts(ind2,:)*g2;
end