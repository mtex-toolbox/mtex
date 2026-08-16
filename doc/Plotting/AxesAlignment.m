%% On Screen Coordinate System Alignment
%%
plottingConvention.default('y↑→x');
%%
% In this section we discuss how MTEX aligns coordinate systems on the
% screen and how to change it. At the same time MTEX tries to be as
% consistent as possible, e.g. by aligning EBSD maps and pole figures with
% respect to the same reference directions.
%
% Different alignments are typically used when
%
% * displaying directions in crystal vs. specimen reference frame
% * displaying orthogonal 2d EBSD sections
%
%% Reference Frames Carry the Alignment
%
% Every plottable quantity in MTEX lives in a reference frame - an
% instance of <referenceFrame.referenceFrame.html |@referenceFrame|> - and
% it is the frame that knows how its data is aligned on screen. The
% alignment itself is described by a |@plottingConvention|, which can be
% read off any object via its |how2plot| property

v1 = vector3d(1,1,1);
v2 = vector3d(-1,1,1);
v1.how2plot

%%
% Freshly created data does not carry a frame of its own - it belongs to
% the session's default frame, |specimenFrame.default|. Every spherical
% plot that is not in crystal coordinates is annotated with the axes of
% that frame, such that the alignment can be read off the plot directly.

plot(v1,'label','v_1','figSize','small')

%%
% Changing the convention of the session frame changes the alignment of
% everything that belongs to it - |v1|, |v2| and all plots to come

plottingConvention.default('y←↑x')
plot(v1,'label','v_1','figSize','small')

%%
% The commands <plotx2east.html |plotx2east|>, |plotx2north|,
% |plotzIntoPlane|, ... do exactly this for the most common cases.
plottingConvention.default('y↑→x');

%% One Plot in a Different Alignment
%
% A single plot may be drawn in any convention by passing it as an option.
% Nothing else is affected - not the data, not the session, not the plot
% after it

plot(v1,'z↑→x','label','v_1')
nextAxis
plot(v2,'label','v_2')

%%
% The convention may be given as a |@plottingConvention| or, as above, by
% the string that names it. A plotting convention belongs to a reference
% frame and never to a data object, so there are exactly three ways to say
% how something should be aligned
%
% * for one plot, |plot(v1,'z↑→x')| as above
% * for the session, |plottingConvention.default('z↑→x')|
% * by moving the data into a named frame that carries its own convention,
%   |v1.frame = specimenFrame.rolling|
%
% Assigning a convention to the data itself - |ebsd.how2plot = 'z↑→x'| - is
% not one of them. It used to attach a private copy of the session frame to
% that one object, which then looked exactly like the session frame in every
% display while silently no longer following it. Such an assignment now
% warns and changes the session instead, and will become an error.

%% Named Reference Frames
%
% Frames have an identity and named axes. The frame of the instrument is
% <specimenFrame.measurement.html |specimenFrame.measurement|> with the
% axes |X1|, |Y1|, |Z1| in Oxford notation. For rolled sheets the frame
% <specimenFrame.rolling.html |specimenFrame.rolling|> names its axes
% |RD|, |TD|, |ND| and comes with the typical rolling geometry
% convention, RD to the north and TD to the west

specimenFrame.rolling

%%
% Any specimen frame can supply the session default. After

specimenFrame.rolling.makeDefault

%%
% all frame-free data plots in the rolling convention and the spherical
% plots annotate RD / TD / ND instead of X / Y / Z - no manual label
% definition required

plot(v2,'upper','label','v_2')

%%
% We return to the generic specimen frame for the rest of this section

specimenFrame.specimen.makeDefault
plottingConvention.default('y↑→x');

%%
% The annotation of the spherical plots is a function handle stored in
% the |pfAnnotations| preference. By default it draws the axes of the
% session's frame with their names; it can be replaced by any custom
% annotation or switched off for the entire session by
%
%   setMTEXpref('pfAnnotations',@(varargin) []);
%
% For a single plot the flag |noLabel| does the same

plot(v1,'upper','label','v_1','noLabel')

%% Imported Data
%
% Imported data follows the session convention like everything else - a
% file does not decide how the rest of your session is drawn. What an
% import may do is state *which frame* the data lives in: data from an
% Oxford instrument lands in |specimenFrame.measurement|, whose axes appear
% as |X1|, |Y1|, |Z1| in the display of the object.

plottingConvention.default('y↑→x');
mtexdata dubna

pf.how2plot
plot(pf{1:4})

%%
% Consequently, all quantities derived from those data are plotted in the
% same alignment

odf = calcODF(pf,'silent');

plotPDF(odf,pf.allH{1:4})

%% Crystal Frames
%
% Data in crystal coordinates, e.g. @Miller directions, lives in the
% crystal frame of its symmetry. The alignment of a crystal frame is not
% a free choice - it is derived from the crystal axes, following the
% alignment options like |X||a| the symmetry was defined with. Its
% display states the alignment and the resulting convention in crystal
% directions, e.g. |⊙c→a| for "c out of screen, a to the east".

cs = crystalSymmetry('321','X||a')

%%
% A pole figure is not crystal framed, although it is computed from crystal
% directions. An orientation is the coordinate transform from its right
% frame to its left one, so |ori * h| lands in the left - the specimen -
% frame, and a pole figure is aligned by the specimen convention.

%% The Reference Frame on EBSD Maps
% On an EBSD or grain map the alignment in use is indicated within the
% scale bar, labeled with the axes names of the frame the map lives in.
% Every axis with a component within the screen plane becomes an arrow,
% the axis along the viewing direction becomes a circled dot if it points
% out of the screen and a circled cross if it points into it.

mtexdata titanium

plot(ebsd,ebsd.orientations,'y↑→x','refFrame','on','figSize','small')

%%
% Changing the plotting convention turns the indicator along with the map

plot(ebsd,ebsd.orientations,'x←↑y','refFrame','on','figSize','small')

%%
% The indicator may be switched off for a single plot by the option
% |'refFrame','off'| or for the entire session by
% |setMTEXpref('showRefFrame','off')|

plot(ebsd,ebsd.orientations,'y↑→x','refFrame','off','figSize','small')

%%
