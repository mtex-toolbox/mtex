%% Grain Reference Orientation Deviation (GROD)
%
%%
% The grain reference orientation deviation asks how far each measurement
% has turned away from the average orientation of its own grain. Where
% <EBSDKAM.html KAM> compares a point with its immediate neighbours and so
% measures how sharply the lattice is bent, the GROD compares it with the
% whole grain and so measures how much the grain has been deformed in
% total. Both the angle of that deviation and the axis it turns about carry
% information, and the axis turns out to say more.
%
% The example is a deformed ferrite specimen. The misorientation axes are
% very sensitive to noise, so the orientations are denoised first - see
% <EBSDDenoising.html Denoising>.

mtexdata ferrite silent

[grains,ebsd] = calcGrains(ebsd,'threshold',[1*degree, 10*degree],'minPixel',3);

% smooth grain boundaries
grains = smoothBoundary(grains,5);

% denoise the orientations
F = halfQuadraticFilter;
ebsd = smooth(ebsd,F,grains,'fill');

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% The deviation angle
%
% <EBSD.calcGROD.html |calcGROD|> computes the deviation as a
% misorientation, one per measurement. It needs the reconstructed grains as
% a second argument, and |ebsd.grainId| to have been set, which the call to
% |calcGrains| above did.

% compute the grain reference orientation deviation
grod = ebsd.calcGROD(grains);

%%
% Its angle plotted as a map, with the subgrain boundaries drawn on top and
% faded in proportion to their own misorientation.

% plot the misorientation angle of the GROD
plot(ebsd,grod.angle./degree,'micronbar','off')
mtexColorbar('title',{'misorientation angle in degree'})
mtexColorMap LaboTeX

% overlay grain and sub-grain boundaries
hold on
plot(grains.boundary,'lineWidth',1.5)
plot(grains.innerBoundary,'edgeAlpha',grains.innerBoundary.misorientation.angle / (5*degree))
hold off

%%
% Half the measurements are within 1.6° of their grain mean and the worst
% reach 18.9°, and the large values are not scattered - they fill whole
% parts of grains, bounded by the subgrain boundaries. A subgrain boundary
% is precisely where the deviation jumps from one level to another.
%
%% Grain orientation spread
%
% Averaging the deviation angle over each grain gives one number per grain,
% the grain orientation spread, and <EBSD.grainMean.html |grainMean|> does
% the averaging.

GOS = grainMean(ebsd, grod.angle, grains);

plot(grains, GOS ./ degree)
mtexColorbar('title','GOS in degree')

%%
% Of the 377 grains the median spread is 0.69° and the largest 6.6°. The
% map is not uniform: some grains took up much more deformation than their
% neighbours, which is what a spread of an order of magnitude between
% grains means.
%
%% The misorientation axis in crystal coordinates
%
% Every deviation also has an axis, and it matters in which frame that axis
% is read. In crystal coordinates it is an $(hk\ell)$ direction of the
% crystal, obtained with <orientation.axis.html |axis|>, and its
% distribution over the fundamental sector is this.

axCrystal = grod.axis;

plot(axCrystal,'contourf','fundamentalRegion','antipodal','figSize','small')
mtexColorbar('title','mrd')

%%
% The whole range is 0.85 to 1.2 times uniform, so in crystal coordinates
% the axes are as good as evenly distributed, with only a slight preference
% for $[101]$. Where they sit in the map is the next question, and it needs
% a colour key for directions.

colorKey = HSVDirectionKey(ebsd.CS,'antipodal');

plot(colorKey,'figSize','small')

%%
% The deviation angle serves as transparency, so that points which have
% barely turned - and whose axis is therefore meaningless - fade to white.

% compute the color from the misorientation axis
color = colorKey.direction2color(axCrystal);

% and set the transparency from the misorientation angle
alpha = min(grod.angle/degree/7.5,1);

% plot the data
plot(ebsd,color,'micronbar','off','faceAlpha',alpha,'figSize','large')

hold on
plot(grains.boundary,'lineWidth',2)
plot(grains.innerBoundary,'edgeAlpha',grains.innerBoundary.misorientation.angle / (5*degree))
hold off

%%
% Whole regions of a grain share one colour, that is one misorientation
% axis, and this is what makes the crystal frame worth looking at: a low
% angle boundary formed by a single slip system has its axis fixed by the
% geometry of that system - a pure tilt wall turns about an axis lying in
% the slip plane and perpendicular to the Burgers vector, a pure twist wall
% about the slip plane normal. A cluster of axes can therefore be matched
% against the candidate slip systems of the phase, which is how V. Tong,
% E. Wielewski and B. Britton identify the active systems in
% <https://arxiv.org/abs/1803.00236 Characterization of slip and twinning
% in high rate deformed zirconium with electron backscatter diffraction>,
% 2018. The <SlipSystems.html slip system> and
% <DislocationSystems.html dislocation system> chapters describe how to set
% those candidates up in MTEX.
%
%% The misorientation axis in specimen coordinates
%
% The same axis in specimen coordinates is the crystal axis carried over by
% the orientation of the measurement. The option |'noSymmetry'| is
% essential here: the axis has to be the one representative that belongs
% to this orientation, not any of its symmetric equivalents.

axSpecimen = ebsd.orientations .* grod.axis('noSymmetry');

plot(axSpecimen,'contourf','fundamentalRegion','antipodal','halfwidth',2.5*degree)
mtexColorbar('title','distribution of misorientation axes in mrd')

%%
% This distribution runs from 0.5 to 5.3 times uniform - the same axes that
% were spread evenly over the crystal are strongly clustered in the
% specimen. That is the expected way round, since the deformation is
% imposed on the specimen and not on any crystal. Whether the maxima are a
% property of the specimen or of a few grains is a question the map can
% answer.
%
% In specimen coordinates the axes have no symmetry at all, not even
% antipodal, so the colour key can use the whole sphere.

colorKey = HSVDirectionKey;

plot(colorKey,'figSize','small')

%%
% The spatial plot follows the same lines as the one in crystal
% coordinates.

% compute color and transparency
omega = min(grod.angle/degree/7.5,1);
color = colorKey.direction2color(axSpecimen);

% plot the data
plot(ebsd,color,'micronbar','off','FaceAlpha',omega,'figSize','large')

hold on
plot(grains.boundary,'lineWidth',2)
plot(grains.innerBoundary,'edgeAlpha',grains.innerBoundary.misorientation.angle / (5*degree))
hold off

%%
% Each deformed grain carries a single colour over large parts of itself,
% and neighbouring grains rarely share it. The maxima of the distribution
% above therefore come from individual grains, not from a pattern running
% across the map - with 377 grains of which only some are strongly
% deformed, that is what should be expected, and a larger map would be
% needed to read the loading geometry off this figure.
%
%% The definition
%
% For the orientation $o_{i,j}$ at position $(i,j)$ in a grain of mean
% orientation $o_g$,
%
% $$ \mathrm{GROD}_{i,j} = \mathbf S_{i,j} \cdot \mathrm{inv}(o_g) \cdot o_{i,j} $$
%
% where the symmetry element $\mathbf S_{i,j}$ is the one that makes the
% misorientation angle as small as possible.
%
