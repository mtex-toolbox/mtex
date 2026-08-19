%% Reference Frame Alignment
%
%%
% The most important difference between MTEX and many other EBSD software
% is that in MTEX the Euler angle reference is always the map reference
% frame. This mean the $x$ and $z$ axes of the map are exactly the rotation
% axes of the Euler angles. 
%
% In case the map coordinates and the Euler angles in your data are with
% respect to different reference frames it is highly recommended to correct
% for this while importing the data into MTEX. This section explains in
% detail how to do this.
%
%% On Screen Orientation of the EBSD Map
%
% Many people are concerned when the images produced by MTEX are not
% aligned exactly as they are in their commercial software. It is indeed
% very important to understand exactly the alignment of your data. However,
% the important point is not whether a map is upside down on your screen or
% not. The important point is how your map aligns with the specimen, as we
% want to use the map to describe properties of the specimen.
%
% There are basically two components in an EBSD data set that refer to the
% specimen reference frame: the spatial coordinates $x$, $y$ and the Euler
% angles $\phi_1$, $\Phi$, $\phi_2$. To explain the difference have a look
% at the EDAX export dialog
% 
% <<edax_coordinate_systems.png>>
% 
% Here we have the axes $x$ and $y$ which describe how the map coordinates
% needs to be interpreted and the axes $A_1$, $A_2$, $A_3$ which describe
% how the Euler angles, and in consequence, the pole figures needs to be
% interpreted. We see that in none of these settings the map reference
% system coincides with the Euler angle reference frame. 
%
% This situation is not specific to EDAX but occurs as well with EBSD data
% from Oxford or Bruker, all of them using different reference system
% alignments. For that reason MTEX strongly recommends to transform the data
% such that both map coordinates and Euler angles refer to the same
% coordinate system. 
% 
% The best way to do this is to rotate the Euler angles such that the Euler
% angle reference frame and the map reference frame coincide. For general
% formats this is done by the options |'EulerCorrection'| followed by the
% rotation that aligns the Euler reference frame with the map reference
% frame. 
% 
% In EDAX software one can choose between several alignments between those
% coordinate system. They are numbered 1 to 4, with setting 2 being the
% most used. As the setting is not stored within the file MTEX assumes
% setting 2 and reminds you about it when importing the data. If your data
% was exported with a different alignment specify it explicitly, and use
% |'setting',0| to switch the correction off. Hence a typical command for
% importing data from an .ang file would look like

plottingConvention.default('y↓→x');
ebsd = EBSD.load([mtexEBSDPath filesep 'olivineopticalmap.ang'],'setting',2)

plot(ebsd('olivine'),ebsd('olivine').orientations,'refFrame','on')

%%
% The plot should already fit the alignment of the map in the EDAX software
% as MTEX by default plots the x-axis to east and the y-axis to the south.
% However, if a different alignment with respect to the screen is more
% useful we can pass the @plottingConvention we want to the plot. This
% affects only that plot - to change the alignment of the whole session
% use |plottingConvention.default| instead.
 
% assume we want x pointing down and y pointing towards east
plot(ebsd('olivine'),ebsd('olivine').orientations,'how2plot','x↓→y','refFrame','on')

%%
% Note that these options only alter the orientation of the EBSD map and
% the pole figures on the screen but does not change any data.
%
%% Verify the reference system
% One way of verifying the reference systems is to visualize crystal shapes
% on top of the orientation map. To do this we proceed as follows

% reconstruct grains
grains = calcGrains(ebsd);

% chose the correct crystal shape (cubic, hex are generic forms)
cS = crystalShape.olivine;

% select only large grains
largeGrains = grains(grains.numPixel>500)

% and plot the crystal shapes
plot(ebsd('olivine'),ebsd('olivine').orientations,'refFrame','on','location','se')
hold on
plot(largeGrains,cS,'colored')
hold off
legend off

%%
% It may also be helpful to inspect pole figures 

h = Miller({1,0,0},{0,1,0},{0,0,1},ebsd('O').CS);
plotPDF(ebsd('O').orientations,h,'contourf')

%%
% As pole figures display data relative to the specimen reference frame
% MTEX automatically aligns them on the screen exactly as the spatial map
% above, i.e., according to our last definition with x pointing towards
% south and y to the east.
%
%% Change the map reference system
% In order to change the map coordinates one may apply a
% rotation to the map coordinates only. E.g. to flip the map left to right
% while preserving the Euler angles one can do

rot = rotation.byAxisAngle(yvector,180*degree);
ebsd_rot = rotate(ebsd,rot,'keepEuler');

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.numPixel>500);

% the crystal shapes are drawn on top of the map - put the reference frame
% box into a corner where none of them covers it
plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations,...
  'refFrame','on','Location','ne')

% and plot the crystal shapes
hold on
plot(largeGrains,cS,'colored')
legend off
hold off

%% Change the Euler angle reference system
% Analogously we may change the Euler angle reference frame while keeping
% the map coordinates

ebsd_rot = rotate(ebsd,rot,'keepXY');

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.numPixel>500);


plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations,...
  'refFrame','on','Location','se')

% and plot the crystal shapes
hold on
plot(largeGrains,cS,'colored')
legend off
hold off


%% Changing both reference system simultaneously
%
% Sometimes it is necessary to relate the EBSD data to a different external
% reference frame, or to  change the external reference frame from one to
% the other, e.g. if one wants to concatenate several ebsd data sets where
% the mounting was not done in perfect coincidence. In these cases the data
% has to be rotated or shifted by the commands <EBSD.rotate.html |rotate|>
% and <EBSD.shift.html |shift|>. The following commands rotate both
% reference frames of the entire data set by 5 degree about the z-axis.

% define a rotation
rot = rotation.byAxisAngle(zvector,5*degree);

% rotate the EBSD data
ebsd_rot = rotate(ebsd,rot);

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.numPixel>500);

plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations,...
  'refFrame','on','Location','se')

% and plot the crystal shapes
hold on
plot(largeGrains,cS,'colored')
legend off
hold off

