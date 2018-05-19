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

function S=hsvconereg(pts)

    
    %%%% The function "hsvconereg" converts points in a
    %%%% cone of unit-radius and unit-height to [r, g, b] color values

    %%% Input: 
    %%% pts: points in a cone of unit-radius and unit-height
    
    %%% Output: 
    %%% (r,g,b) Refer to the cone on the left-hand side of "Figure S1"
    %%% in the supplementary information of the paper titled
    %%% "Improved representations of misorientation information for grain
    %%% boundary science and engineering"
    
    rho = atan2(pts(:,2),pts(:,1)); maxrho = 2*pi; rho = mod(rho,maxrho)./maxrho;
    c = hsv2rgb(rho, sqrt(pts(:,1).^2 + pts(:,2).^2)./(pts(:,3) + 1*(pts(:,3)==0)),pts(:,3));
    S = reshape(c,[size(pts,1),3]);
    S = 1-S;
    
end