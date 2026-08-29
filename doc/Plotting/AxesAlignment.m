%% Axes Alignment on Screen
%
%%
% Axes alignment answers which reference-frame direction points north,
% east or out of the screen. MTEX uses the same plotting convention for an
% EBSD map and the pole figures derived from it, so the same specimen
% directions remain aligned across figures.
%
% Changing a plotting convention changes only how data is drawn. It does
% not rotate the physical object or re-express it in another reference
% frame. Different conventions are useful when comparing crystal and
% specimen directions or viewing orthogonal two-dimensional EBSD sections.

plottingConvention.default('y↑→x');

%% Reference Frames Carry the Alignment
%
% A <referenceFrame.referenceFrame.html reference frame> identifies where
% coordinates are expressed, supplies a basis and provides a default
% convention for drawing them. The point-group symmetry attached to a
% frame is a separate property. A |@plottingConvention| describes the
% on-screen alignment, and the read-only |how2plot| property reports the
% convention that an object will use.

v1 = vector3d(1,1,1);
v2 = vector3d(-1,1,1);
v1.how2plot

%%
% The display states that y points north and x points east. Freshly created
% vectors are frame-free: their frame is empty, and their convention is
% resolved against |specimenFrame.default| when they are drawn. Pointing at
% the default frame instance would instead make them framed data.
%
% A spherical plot outside crystal coordinates is annotated with the axis
% names of the session's default specimen frame. The labels therefore make
% the alignment visible in the figure.

plot(v1,'label','v_1','figSize','small')

%%
% The labels show x to the east and y to the north. Changing the convention
% of the session frame changes frame-free and default-framed objects,
% including |v1| and |v2|, and affects subsequent plots.

plottingConvention.default('y←↑x');
plot(v1,'label','v_1','figSize','small')

%%
% Now y points west and x points north, so the marker and annotations turn
% together. The commands <plotx2east.html |plotx2east|>,
% <plotx2north.html |plotx2north|> and
% <plotzIntoPlane.html |plotzIntoPlane|> set common session conventions.
plottingConvention.default('y↑→x');

%% One Plot in a Different Alignment
%
% A single plot may be drawn in any convention by passing it as an option.
% The arrow string states the frame directly: in |'z↑→x'|, z points north
% and x points east. This override affects neither the data nor the session.

plot(v1,'how2plot','z↑→x','label','v_1')
nextAxis
plot(v2,'label','v_2')

%%
% Each command draws an upper and a lower panel, so the figure holds four
% disks. The first pair uses the explicit z-north convention. Under it the
% out-of-screen direction is $-y$, which puts $v_1$ in the lower panel of
% that pair and leaves its upper panel empty. The second pair returns to the
% session convention, so the override is local to the plot that asked for it.
%
% A convention may be passed as a |@plottingConvention| or as the string
% that names it. A plotting convention belongs to a reference frame, never
% directly to a data object. There are three ways to choose an alignment:
%
% * for one plot, |plot(v1,'how2plot','z↑→x')| as above
% * for the session, |plottingConvention.default('z↑→x')|
% * by associating data with a named frame that carries its own convention,
%   |v1.frame = specimenFrame.rolling|
%
% Assigning a convention to the data itself, such as
% |ebsd.how2plot = 'z↑→x'|, is not one of them. The |how2plot| property is
% read-only except on @referenceFrame. The old assignment syntax attached a
% private copy of the session frame to one object. That copy looked like the
% session frame in displays but silently stopped following later changes.

%% Named Reference Frames
%
% A specimen frame has an identity and named axes. The frame in which an
% Oxford instrument states Euler angles is
% <specimenFrame.specimenFrame.html |specimenFrame.measurement|> with the
% axes |X1|, |Y1| and |Z1| in Oxford notation: the sample surface CS1. For
% rolled sheets the frame
% <specimenFrame.specimenFrame.html |specimenFrame.rolling|> names its axes
% |RD|, |TD| and |ND|. Its typical rolling convention puts RD to the north
% and TD to the west.

specimenFrame.rolling

%%
% The object summary reports both the named axes and their convention. Any
% specimen frame can supply the session default. After

specimenFrame.rolling.makeDefault

%%
% frame-free data uses the rolling convention, and spherical plots annotate
% RD, TD and ND rather than X, Y and Z. No manual labels are required.

plot(v2,'upper','label','v_2')

%%
% The annotations now name the rolling axes, while the vector coordinates
% themselves are unchanged. Return to the generic specimen frame for the
% rest of the page.

specimenFrame.specimen.makeDefault
plottingConvention.default('y↑→x');

%%
% The |pfAnnotations| preference stores the function that annotates
% spherical plots. By default it draws the named axes of the session frame.
% It can be replaced by a custom annotation or disabled for the session:
%
%   setMTEXpref('pfAnnotations',@(varargin) []);
%
% For one plot, |'noLabel'| suppresses the frame annotation instead.

plot(v1,'upper','label','v_1','noLabel')

%%
% The vector label remains, but the reference-frame axis labels are absent.

%% Imported Data
%
% An imported file does not decide how the rest of the session is drawn.
% No vendor gives the map a specimen-frame identity, so imported positions
% use the generic specimen frame with axes |X|, |Y| and |Z|. Associate an
% EBSD map with a named frame, for example
% |ebsd.frame = specimenFrame.rolling|, once its specimen directions are
% known. This labels the existing coordinates; it is not a frame change.

plottingConvention.default('y↑→x');
mtexdata dubna silent

pf.how2plot
plot(pf{1:4})

%%
% The printed convention and the axis annotations agree. The four pole
% figures use the same specimen alignment. Quantities derived from these
% data inherit that alignment.

odf = calcODF(pf,'silent');

plotPDF(odf,pf.allH{1:4})

%%
% The reconstructed ODF produces pole figures with the same axis placement
% as the imported measurements, so corresponding peaks can be compared.

%% Crystal Frames
%
% Data in crystal coordinates, such as @Miller directions, uses the crystal
% frame attached to its symmetry. A crystal frame is the Cartesian
% reference frame fixed to the lattice basis. Its alignment follows the
% crystal axes and the frame options used when the symmetry was created,
% such as X parallel to a. The symmetry display states the resulting
% convention in crystal directions, for example |⊙c→a| means c points out
% of the screen and a points east.

cs = crystalSymmetry('321','X||a')

%%
% The summary reports the crystal-frame alignment. A pole figure itself is
% not crystal-framed, although it is computed from crystal directions. An
% orientation maps coordinates from its right frame to its left frame, so
% |ori * h| lies in the left, specimen frame. The pole figure consequently
% uses the specimen convention.

%% The Reference-Frame Indicator on EBSD Maps
%
% An EBSD or grain map shows its alignment inside the scale-bar box. The
% indicator uses the axis names of the map's reference frame. An axis with
% an in-plane component is drawn as an arrow. An axis along the viewing
% direction becomes a circled dot when it points out of the screen and a
% circled cross when it points into the screen.

mtexdata titanium silent

ipfKey = ipfColorKey(ebsd.orientations);
ipfColor = ipfKey.orientation2color(ebsd.orientations);

plot(ebsd,ipfColor,'how2plot','y↑→x','refFrame','on','figSize','small')

%%
% The indicator shows y north and x east, matching the explicit convention.
% Changing the plotting convention turns the indicator with the map.

figure
plot(ebsd,ipfColor,'how2plot','y←↑x','refFrame','on','figSize','small')

%%
% In the second map y points west and x points north. The colours remain
% attached to the same measurements while the map and indicator rotate.
% The indicator can be disabled for one plot with |'refFrame','off'| or for
% the entire session with |setMTEXpref('showRefFrame','off')|.

plot(ebsd,ipfColor,'how2plot','y↑→x','refFrame','off','figSize','small')

%%
% The final map keeps the first alignment but omits only the indicator.
%
%% Next
%
% Once related figures share a reference-frame alignment,
% <CombinedPlots.html Combined Plots> shows how to overlay them or arrange
% them in comparable panels.
%
%% Further reading
%
% Britton et al., <https://doi.org/10.1016/j.matchar.2016.04.008 Crystal
% orientations and EBSD - or which way is up?>, explains why explicit
% frame conventions are essential when EBSD data moves between software.
% <https://www.iso.org/standard/82749.html ISO 24173:2024> gives the current
% international guidance for reproducible EBSD orientation measurements.
