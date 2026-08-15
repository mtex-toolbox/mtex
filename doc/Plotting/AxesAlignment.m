%% On Screen Coordinate System Alignment
%%
plottingConvention.default('y↑→x');
%%
% In this section we discuss how MTEX aligns coordinate systems on the
% screen and how to change it. In MTEX it is possible to mix different
% alignment. At the same time MTEX tries to be as consistent as possible,
% e.g. by aligning EBSD maps and pole figures with respect to the same
% reference directions.
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

%% A Private Alignment for a Single Object
%
% Assigning to the |how2plot| property of an object detaches it from the
% session frame: the object receives a private copy of the frame carrying
% the new convention. Other data is not affected - in particular |v2|
% keeps the session alignment

v1.how2plot = plottingConvention('z↑→x');

% plot v1 and v2 in separate plots
plot(v1,'upper','label','v_1')
nextAxis
plot(v2,'upper','label','v_2')

%%
% This is a deliberate change compared to MTEX 6, where |how2plot| was a
% shared handle and changing it on one vector silently changed it on all
% others. If the intent is "change it everywhere", say so by changing the
% session frame via |plottingConvention.default| as above.

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
% We return to the generic specimen frame for the rest of this section.
% Note that this does not affect |v1|, which still carries the private
% frame it received above - assigning |[]| to its |how2plot| releases
% the private frame, so |v1| follows the session default again

specimenFrame.specimen.makeDefault
plottingConvention.default('y↑→x');
v1.how2plot = [];

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
% Imported data may come with its own idea how it wants to be plotted on
% screen. Such a convention applies to the whole session: the session
% frame adopts it and the imported data joins the session frame.

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

%% The Reference Frame on EBSD Maps
% On an EBSD or grain map the alignment in use is indicated within the
% scale bar, labeled with the axes names of the frame the map lives in.
% Every axis with a component within the screen plane becomes an arrow,
% the axis along the viewing direction becomes a circled dot if it points
% out of the screen and a circled cross if it points into it.

mtexdata titanium

ebsd.how2plot = 'y↑→x';
plot(ebsd,ebsd.orientations,'refFrame','on','figSize','small')

%%
% Changing the plotting convention turns the indicator along with the map

ebsd.how2plot = 'x←↑y';
plot(ebsd,ebsd.orientations,'refFrame','on','figSize','small')

%%
% The indicator may be switched off for a single plot by the option
% |'refFrame','off'| or for the entire session by
% |setMTEXpref('showRefFrame','off')|

ebsd.how2plot = 'y↑→x';
plot(ebsd,ebsd.orientations,'refFrame','off','figSize','small')

%%
