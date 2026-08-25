%% ODF Component Analysis
%
%%
% A texture is usually described as a handful of *components* - preferred
% orientations that different deformation or recrystallisation processes
% produced. Reading an ODF means finding those components and saying how
% much material belongs to each.
%
% The example is a quartz ODF reconstructed from neutron pole figure data.

% import Neutron pole figure data from a Quartz specimen
plottingConvention.default("y↑→x");
mtexdata dubna silent

% reconstruct the ODF
odf = calcODF(pf,'zeroRange');

% visualize the ODF in sigma sections
plotSection(odf,'sigma','sections',12,'layout',[3,4])
mtexColorbar

%% The Preferred Orientation
%
% The ODF has one strong maximum. <SO3Fun.max.html |max|> returns both its
% value and where it sits.

[value,ori] = max(odf)

%%
% As with the MATLAB
% <https://de.mathworks.com/help/matlab/ref/max.html |max|>, the second
% output is where the maximum is attained - here 110 times random. Drawn
% into the sigma sections it lands on the brightest spot.

annotate(ori)

%%
% |max| also finds local maxima, as many as asked for with |'numLocal'| -
% which is the first step of a component analysis.

[value,ori] = max(odf,'numLocal',3)

annotate(ori(2:end),'MarkerFaceColor','red')

%%
% The orientations come back sorted by ODF value: 110, 47 and less.
%
%% Volume Fractions
%
% The ODF value at a component is not a measure of its importance. A very
% sharp component reaches a huge value while occupying almost no volume,
% see <ODFTheory.html Theory>. What matters is the fraction of material
% within a given disorientation angle of it, which is
% <SO3Fun.volume.html |volume(odf,ori,delta)|>.

delta = 10*degree;
volume(odf,ori,delta) * 100


%%
% 11, 5 and 4 percent - together far short of 100, which is entirely
% typical. The reason is that a $10^\circ$ ball is a tiny part of
% orientation space to begin with: in a uniform texture it would hold

volume(uniformODF(odf.CS),ori(1),delta) * 100

%%
% only 0.17 percent of the material. Against that reference the components
% are enormous - the ratio is how many times more material sits there than
% a uniform texture would put there.

volume(odf,ori,delta) ./ volume(uniformODF(odf.CS),ori,delta)

%%
% 67, 31 and 24 times. Every number in this section depends on the
% disorientation angle |delta|, and choosing it too large makes the
% components overlap.

delta = 40*degree
volume(odf,ori,delta)*100

%%
% At $40^\circ$ the three balls together account for more than 100 percent
% of the material, since the same crystals are counted in several of them.
%
%% Components That Are Not Balls
%
% Fixing one radius for every component is the weakness of the approach:
% real components are not spherical and neighbouring ones run into each
% other. <SO3Fun.calcComponents.html |calcComponents|> avoids the choice
% altogether. It starts from evenly distributed orientations and lets each
% of them crawl uphill to the nearest maximum, then reports the maxima
% together with the share of orientations that arrived at each.

[ori, vol] = calcComponents(odf);
ori
vol * 100

%%
% 48, 22, 21 and 7 percent - these shares always add up to about 100, since
% every orientation ends up somewhere. The maxima themselves agree with
% those found by |max|, which the white circles show.

annotate(ori,'MarkerFaceColor','none','MarkerEdgeColor','white',...
  'linewidth',2,'MarkerSize',15,'marker','o')

%#ok<*ASGLU>
%#ok<*NOPTS>

%% Next
%
% Fitting model components to an ODF rather than locating them is
% <ODFModeling.html Modeling>, and the single numbers that summarise a
% whole ODF are <ODFCharacteristics.html Properties>.
