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

function volpres = rodri2volpreserv(pts)

    %%%% The function converts points rodrigues vector, which is a Geodesic
    %%%% projection, to the volume-preserving projection

    %%% Input: 
    %%% pts: Rodrigues vector (r1, r2, r3) N X 3 (N points)
    
    %%% Output: 
    %%% volpres (N X 3) - volume-preserving projection
    
    d1 = pts(:,1); d2 = pts(:,2); d3 = pts(:,3);
    q0 = sqrt(1./(1+ d1.^2 + d2.^2 + d3.^2));
    q1 = d1.*q0; q2 = d2.*q0; q3 = d3.*q0; 
    alphang = acos(q0);
    r = (3*(alphang - sin(alphang).*cos(alphang))/2).^(1/3);
    x1 = (q1.*r)./(sin(alphang) + 1*(sin(alphang)==0));
    y1 = (q2.*r)./(sin(alphang) + 1*(sin(alphang)==0));
    z1 = (q3.*r)./(sin(alphang) + 1*(sin(alphang)==0));
    % scatter3(x1,y1,z1,'Marker','.');

    volpres = [x1 y1 z1];