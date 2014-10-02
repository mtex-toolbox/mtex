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

function areapres = areapreservingx(pts)
    %%% Input: 
    %%% pts: Points on the surface a sphere
    
    %%% Output: 
    %%% (y1, z1):   Points on the plane obtained by projecting "pts"
    %%%             using area-preserving projection along the x-axis
    
    rad = sqrt(pts(:,1).^2 + pts(:,2).^2 + pts(:,3).^2);
    
    y1 = pts(:,2).*rad.*sqrt(2*(1-abs((pts(:,1))./(rad))))./...
        ((sqrt(rad.^2 - pts(:,1).^2)) + 1*((sqrt(rad.^2 - pts(:,1).^2))==0));
    z1 = pts(:,3).*rad.*sqrt(2*(1-abs((pts(:,1))./(rad))))./...
        ((sqrt(rad.^2 - pts(:,1).^2)) + 1*((sqrt(rad.^2 - pts(:,1).^2))==0));
    areapres = [y1 z1];

end