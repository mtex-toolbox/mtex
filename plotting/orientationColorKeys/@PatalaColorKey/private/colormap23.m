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

function S = colormap23(v)

pts = reshape(double(v),[],3);

pts(pts(:,1) > 1,1)=1;
pts(pts(:,2) > 1,2)=1;
pts(pts(:,3) > 1,3)=1;

%%% Step 2 = Rotation and alignment %%%%
% % % g1 = rotvec2mat([1,1,1,pi/4]);
% % % g2 = rotvec2mat([-1,1,0,acos(1/sqrt(3))]);
% % % g3 = rotvec2mat([0,0,1,-pi/3]);
% % % pts = pts*g1*g2*g3;

pts = pts*rotvec2mat([1,1,1,pi/4])* ...
    rotvec2mat([-1,1,0,acos(1/sqrt(3))])*rotvec2mat([0,0,1,-pi/3]);

%%% Step 3 = Prism to cone %%%%
tempvar = 2*(pts(:,1).^2 + pts(:,2).^2).^(3/2);
tempvar1 =         pts(:,1) + sqrt(3)*pts(:,2);
tempvar2 =         pts(:,1) - sqrt(3)*pts(:,2);
tempvar3 = sqrt(3)*pts(:,1) +         pts(:,2);
tempvar4 = sqrt(3)*pts(:,1) -         pts(:,2);

tempx=pts(:,1).*(tempvar1).*(tempvar1).*(tempvar2);
tempy=pts(:,2).*(tempvar1).*(tempvar3).*(tempvar4);

pts(:,1)=tempx./(tempvar+1*(tempvar==0)); 
pts(:,2)=tempy./(tempvar+1*(tempvar==0));
pts(:,3)=pts(:,3).*sqrt(3);

g3 = rotvec2mat([0,0,1,pi]);
pts = pts*g3;
S = hsvconereg(pts);


