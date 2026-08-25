%% Reference Frame Alignment
%
%%
% Every EBSD data set states two things about the specimen: where each
% measurement was taken, and how the crystal there is oriented. The
% positions are $x$, $y$ coordinates in the map, the orientations are Euler
% angles, and both are given with respect to some coordinate system. If
% those two coordinate systems are not the same one, then position and
% orientation cannot be compared, and every result that combines them - a
% grain shape against its crystal, a pole figure against the map - is
% wrong in a way the numbers do not reveal.
%
% MTEX therefore insists on one rule: *the Euler angles refer to the map
% reference frame*. The $x$ and $z$ axes of the map are exactly the axes
% the Euler angles turn about. Data that arrives otherwise is corrected on
% import, and this page is about doing that correctly.
%
%% The two frames in a data file
%
% Nothing in a vendor file forces the two frames to agree, and in practice
% they usually do not. The EDAX export dialog shows the situation plainly
%
% <<edax_coordinate_systems.png>>
%
% The axes $x$ and $y$ say how the map coordinates are to be read. The axes
% $A_1$, $A_2$, $A_3$ say how the Euler angles are to be read, and hence
% how every pole figure computed from them comes out. In none of the four
% settings offered do the two coincide. Oxford and Bruker files have the
% same problem with different alignments.
%
% EDAX numbers these alignments 1 to 4, of which setting 2 is by far the
% most common. The number is not stored in the file, so MTEX assumes
% setting 2 and says so when importing an |.ang| file. State it explicitly
% if your export used another one, or pass |'setting',0| to switch the
% correction off.

plottingConvention.default('y↓→x');

ebsd = EBSD.load([mtexEBSDPath filesep 'olivineopticalmap.ang'],'setting',2)

%%
% For a format that offers no such catalogue the correction is given
% directly, as the rotation that takes the Euler angle axes onto the map
% axes
%
%   ebsd = EBSD.load(fileName,'EulerCorrection',rotation.map(xvector,xvector,zvector,-zvector))
%
% Either way the data is now consistent, and can be plotted. The small box
% in the corner is switched on by |'refFrame','on'| and states the
% alignment being used - here $x$ to the east, $y$ to the south and $z$
% into the screen.

plot(ebsd('olivine'),ebsd('olivine').orientations,'refFrame','on')

%% Where the map sits on the screen is a different question
%
% People are often troubled when a map does not appear on screen the way
% their commercial software drew it. That is worth separating from the
% question above. Whether the map is upside down on the screen is a matter
% of taste; whether it is aligned with the specimen is a matter of
% correctness, and only the second one can invalidate an analysis.
%
% The screen alignment is held by a @plottingConvention, and passing one to
% a single plot changes that plot alone.

% assume we want x pointing down and y pointing towards east
plot(ebsd('olivine'),ebsd('olivine').orientations,'how2plot','x↓→y','refFrame','on')

%%
% The map has turned a quarter turn - the large red grain that sat at the
% right edge is now at the bottom - but every grain kept its colour,
% because no orientation and no coordinate was touched. To change the
% alignment for a whole session rather than for one plot use
% |plottingConvention.default| instead, as at the top of this page.
%
%% Checking the alignment against the specimen
%
% Since no number in the data set reveals a wrong frame, the check has to
% come from the material. The most direct one is to draw each grain's
% crystal in the orientation that was measured for it, and see whether the
% crystal fits the grain it sits on.

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
% Eight grains are large enough here. Most of them are nearly equant and
% say little, but the elongated grain on the right edge carries an
% elongated crystal pointing the same way, which is what a grain grown in a
% rock does. A wrong frame would show the crystals systematically turned
% against their grains, or mirrored.
%
% The second check is the pole figure.

h = Miller({1,0,0},{0,1,0},{0,0,1},ebsd('O').CS);
plotPDF(ebsd('O').orientations,h,'contourf')

%%
% Pole figures describe directions in the specimen, so MTEX draws them in
% the same frame as the map above, $x$ to the east and $y$ to the south.
% A direction read off the map is therefore the same direction read off the
% pole figure, and a texture that ought to line up with a feature of the
% map - a foliation, a rolling direction - can be checked against it
% directly. All three pole figures here show a few sharp maxima rather than
% an even covering, so the specimen is textured, and the strongest (010)
% maximum sits on the eastern rim, which is the $x$ axis of the map.
%
%% Changing the map coordinates alone
%
% All three corrections below act after import, on data that is already
% consistent. Rotating only the map coordinates flips or turns the picture
% while leaving the orientations as they are - useful when the map was
% recorded mirrored with respect to the specimen.

rot = rotation.byAxisAngle(yvector,180*degree);
ebsd_rot = rotate(ebsd,rot,'keepEuler');

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.numPixel>500);

% the crystal shapes are drawn on top of the map - put the reference frame
% box into a corner where none of them covers it
plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations, ...
  'refFrame','on','Location','ne')

% and plot the crystal shapes
hold on
plot(largeGrains,cS,'colored')
legend off
hold off

%%
% The map is mirrored left to right - the large red grain has moved from
% the right edge to the left - while each crystal is drawn exactly as
% before, at the mirrored position of its grain. The two frames have been
% pulled apart on purpose, and yet the result still looks like a perfectly
% ordinary map. That is what a wrongly imported data set looks like, and
% why the correction belongs at import.
%
%% Changing the Euler angles alone
%
% The opposite operation keeps the coordinates and turns the orientations.

ebsd_rot = rotate(ebsd,rot,'keepXY');

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.numPixel>500);

plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations, ...
  'refFrame','on','Location','se')

% and plot the crystal shapes
hold on
plot(largeGrains,cS,'colored')
legend off
hold off

%%
% Now the grains are where they were and the crystals turned instead. The
% colours, however, did not change at all: the key asks which crystal
% direction points along $z$, this rotation sends that direction to its
% opposite, and olivine has an inversion centre, so the answer is the same
% one. Colour alone can therefore not tell you that a frame is wrong -
% only something with a shape can.
%
%% Changing both frames together
%
% Rotating both frames at once leaves the data self consistent and moves it
% as a whole with respect to the outside world. This is what is needed to
% relate a map to an external reference frame, or to bring several maps
% into a common one when the specimens were not mounted identically. The
% commands are <EBSD.rotate.html |rotate|> and <EBSD.shift.html |shift|>.

% define a rotation
rot = rotation.byAxisAngle(zvector,5*degree);

% rotate the EBSD data
ebsd_rot = rotate(ebsd,rot);

% reconstruct grains
grains = calcGrains(ebsd_rot('indexed'));

% select only large grains
largeGrains = grains(grains.numPixel>500);

plot(ebsd_rot('olivine'),ebsd_rot('olivine').orientations, ...
  'refFrame','on','Location','se')

% and plot the crystal shapes
hold on
plot(largeGrains,cS,'colored')
legend off
hold off

%%
% The whole map is tilted by five degrees and the crystals came along, so
% they still fit their grains.
%
