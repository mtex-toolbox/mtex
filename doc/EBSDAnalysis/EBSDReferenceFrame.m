%% Reference Frame Alignment
%
%%
% The most important difference between MTEX and many other EBSD software
% is that in MTEX the Euler angle reference is always the map reference
% frame. This mean the $x$ and $z$ axes of the map are exactly the rotation
% axes of the Euler angles. 
%
% In case the map coordinates and the Euler angles in your data are with
% respect to different reference frames it is highly recommendet to correct
% for this while importing the data into MTEX. This section explains in
% detail how to do this.
%
%% On Sreen Orientation of the EBSD Map
%
% Many peoply are concerned when the images produced by MTEX are not
% aligned exactly as they are in their commercial software. It is indeed
% very important to understand exactly the alignment of you data. However,
% the important point is not whether a map is upside down on you screen or
% not. The important point is how your map alignes with the specimen, as we
% want to use the map to describe properties of the specimen.
%
% There are basicaly two components in an EBSD data set that refers to the
% specimen reference frame: the spatial coordinates $x$, $y$ and the Euler
% angles $\phi_1$, $\Phi$, $\phi_2$. To explain the difference have a look
% at the EDAX export dialog
% 
% <<edax_coordinate_systems.png>>
% 
% Here we have the axes $x$ and $y$ which describe how the map coordinates
% needs to be interpreted and the axes $A_1$, $A_2$, $A_3$ which describe
% how the Euler angles, and in consequence, the pole figures needs to be
% interpreted. We see that in non of these settings the map reference
% system coincides with the Euler angle reference frame. 
%
% This situation is not specific to EDAX but occurs as well with EBSD data
% from Oxford or Bruker, all of them using different reference system
% alignments. For that reason MTEX stronly recommends to transform the data
% such that both map coordinates and Euler angles refer to the same
% coordinate system. 
%
% Doing this we have two choices:
%
% # transfrom everything to the reference system $x$, $y$ using the option
% |'convertEuler2SpatialReferenceFrame'|. This will keep the map
% coordinates while changing the Euler angles
% # transfrom everything to the reference system $A_1$, $A_2$, $A_3$ using
% the option |'convertSpatial2EulerReferenceFrame'|. This will keep the
% Euler angles while changing the map coordinates.
% 
% In the case of EDAX data imported from an |*.ang| file we still need to
% specify the export option used by the EDAX software. This is done by the
% options |'setting 1'|, |'setting 2'|, |'setting 3'| or |'setting 4'|.
%
% Since setting 2 is default for most EDAX exports a typical command for
% importing data from an ang file would look like this

ebsd = EBSD.load([mtexEBSDPath filesep 'olivineopticalmap.ang'],...
  'convertEuler2SpatialReferenceFrame','setting 2')

plot(ebsd('olivine'),ebsd('olivine').orientations,'coordinates','on')

%%
% The plot does not yet fit the alignment of the map in the EDAX software
% as it plots the x-axis be default to east and the z-axis into the plane.
% This is only a plotting convention and can be set in MTEX by

plotx2east
plotzIntoPlane

plot(ebsd('olivine'),ebsd('olivine').orientations,'coordinates','on')

%%
% Other plotting conventions are |plotx2north|, |plotx2west|, |plotx2south|
% and |plotzOutOfPlane|. Note that these options only alter the orientation
% of the EBSD map and the pole figures on the screen but does not change
% any data.
%
%% Verify the reference system
% One way of veryfying the reference systems is to visualize crystal shapes
% on top of the orientation map. To do this we proceed as follows

% reconstruct grains
grains = calcGrains(ebsd('indexed'));

% chose the correct crystal shape (cubic, hex are generic forms)
cS = crystalShape.olivine;

% select only large grains
largeGrains = grains(grains.grainSize>500)

% and plot the crystal shapes
hold on
plot(largeGrains,cS)
hold off

%%
% It may also be helpfull to inspect pole figures 

h = Miller({1,0,0},{0,1,0},{0,0,1},ebsd('O').CS);
plotPDF(ebsd('O').orientations,h,'contourf')

%%
% As pole figures display data relative to the specimen reference frame
% MTEX automatically aligns them on the screen exatcly as the spatial map
% above, i.e., according to our last definition with x pointing towards
% east and y to the south.
%
%% Change the map reference system
% In order to manualy change the map reference frame one may apply a
% rotation to the map coordinates only. E.g. to flip the map left to right
% while preserving the Euler angles one can do

rot = rotation.byAxisAngle(yvector,180*degree);
ebsd_rot = rotate(ebsd,rot,'keepEuler');

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.grainSize>500);


plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations,'coordinates','on')

% and plot the crystal shapes
hold on
plot(largeGrains,cS)
hold off


%% Change the Euler angle reference system
% Analogously we may change the Euler angle reference frame while keeping
% the map coordinates

ebsd_rot = rotate(ebsd,rot,'keepXY');

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.grainSize>500);


plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations,'coordinates','on')

% and plot the crystal shapes
hold on
plot(largeGrains,cS)
hold off


%% Changing both reference system simultanously
%
% Sometimes it is necessary to relate the EBSD data to a different external
% reference frame, or to  change the external reference frame from one to
% the other, e.g. if one wants to concatenate several ebsd data sets where
% the mounting was not done in perfect coincidence. In these cases the data
% has to be rotated or shifted by the commands <EBSD.rotate.html rotate>
% and <EBSD.shift.html shift>. The following commands rotate both reference
% frames of the entire data set by 5 degree about the z-axis.

% define a rotation
rot = rotation.byAxisAngle(zvector,5*degree);

% rotate the EBSD data
ebsd_rot = rotate(ebsd,rot);

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.grainSize>500);


plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations,'coordinates','on')

% and plot the crystal shapes
hold on
plot(largeGrains,cS)
hold off

