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

%-------------------------------------------------------------------------%
%Filename:  testPatalaColorcodeMTEX.m
%Author:    Oliver Johnson
%Date:      10/25/2013
%
% This file is intended to test the code for using the Patala colorcoding
% for grain boundaries. Run each cell (section of code) one at a time, by
% pressing CTRL+SHIFT+ENTER. Once one cell has finished running press
% CTRL+SHIFT+ENTER to run the next cell.
%-------------------------------------------------------------------------%

%% Load Test Data

load('testdata.mat')

plotx2east

%% Point Group 23

close all

%---set the symmetry---%
ebsd = set(ebsd,'CS',symmetry('23'));

%---segment ebsd data into grains---%
grains = calcGrains(ebsd);
grains = calcGrains(grains(grainSize(grains) > 20));

%---plot boundaries---%
figure
plotBoundary(grains,'property','misorientation',...
  'colorcoding','patala','linewidth',2);

%---create colorbars---%
colorbar('omega',[5,15,25,35,45,55,65,75,85])

%% Point Group 222

close all

%---set the symmetry---%
ebsd = set(ebsd,'CS',symmetry('222'));

%---segment ebsd data into grains---%
grains = calcGrains(ebsd);
grains = calcGrains(grains(grainSize(grains) > 20));

%---plot boundaries---%
figure
plotBoundary(grains,'property','misorientation','colorcoding','patala');

%---create colorbars---%
colorbar('omega',[5,15,25,35,45,55,65,75,85,95,105,115])

%% Point Group 422

close all

%---set the symmetry---%
ebsd = set(ebsd,'CS',symmetry('422'));

%---segment ebsd data into grains---%
grains = calcGrains(ebsd);
grains = calcGrains(grains(grainSize(grains) > 20));

%---plot boundaries---%
figure
plotBoundary(grains,'property','misorientation','colorcoding','patala');

%---create colorbars---%
colorbar('omega',[5,15,25,35,45,55,65,75,85,95])

%% Point Group 432

close all

%---set the symmetry---%
ebsd = set(ebsd,'CS',symmetry('432'));

%---segment ebsd data into grains---%
grains = calcGrains(ebsd);
grains = calcGrains(grains(grainSize(grains) > 20));

%---plot boundaries---%
figure
plotBoundary(grains,'property','misorientation','colorcoding','patala');

%---create colorbars---%
colorbar('omega',[2.5:5:57.5,61.3997])

%% Point Group 622

close all

%---set the symmetry---%
ebsd = set(ebsd,'CS',symmetry('622'));

%---segment ebsd data into grains---%
grains = calcGrains(ebsd);
grains = calcGrains(grains(grainSize(grains) > 20));

%---plot boundaries---%
figure
plotBoundary(grains,'property','misorientation','colorcoding','patala');

%---create colorbars---%
colorbar('omega',[5,15,25,35,45,55,65,75,85,92])
