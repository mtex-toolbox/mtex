%% Fibres of Orientations
%
%%
% A fibre is a curve through orientation space, stored as a single variable
% of type <fibre.fibre.html |@fibre|>. Fibres matter because many real
% textures are not a point but a line: all orientations that put one crystal
% direction along one specimen direction, with the rotation about it left
% free. The rolling textures of cubic metals are described almost entirely
% in these terms.
%
% To see how one is built, take the |cube| and the |goss| orientation

% define crystal and specimen symmetry
cs = crystalSymmetry('432');
ss = specimenSymmetry('1');

% and two orientations
ori1 = orientation.cube(cs,ss);
ori2 = orientation.goss(cs,ss);

%%
% and then the fibre connecting both orientations

f = fibre(ori1,ori2)

%%
% Finally we plot everything into the Euler space

% plot the fibre
plot(f,'DisplayName','Fibre','linewidth',4,'linecolor','green')

% and on top of it the orientations
hold on
plot(ori1,'DisplayName','CUBE','MarkerSize',12,'MarkerFaceColor','darkred','MarkerEdgeColor','k')
plot(ori2,'DisplayName','GOSS','MarkerSize',12,'MarkerFaceColor','blue','MarkerEdgeColor','k')
hold off
legend('Location','northwest')

%%
% The green line runs from the one orientation to the other - it is the
% shortest path between them, the orientation space equivalent of a straight
% line. The same fibre in axis angle space:

% plot the fibre
plot(f,'linecolor','green','linewidth',6,'axisAngle')

% and on top of it the orientations
hold on
plot(ori1,'MarkerFaceColor','darkred','MarkerSize',15,'axisAngle')
plot(ori2,'MarkerFaceColor','blue','MarkerSize',15)
hold off

%%
% What is drawn so far is only the segment between the two orientations.
% Orientation space has no boundary, so continuing along the curve brings it
% back to where it started: a full fibre is a circle through the two
% orientations. That is the option |'full'|.

f = fibre(ori1,ori2,'full')

hold on
plot(f,'linecolor','gold','linewidth',3,'project2FundamentalRegion')
hold off


%% Fibres in Pole Figures and Inverse Pole Figures
%
% Everything that can be plotted for orientations can be plotted for fibres,
% <OrientationPoleFigure.html pole figures> and
% <OrientationInversePoleFigure.html inverse pole figures> included, through
% <fibre.plotPDF.html |plotPDF|> and <fibre.plotIPDF.html |plotIPDF|>. A
% fibre becomes a curve rather than a point in each of them.

plotPDF(f,Miller({1,1,0},{1,1,1},cs),'linewidth',3,'lineColor','orange')

%%
% One difference to orientation plots matters: a fibre is *not*
% automatically symmetrised, so the plot above shows one curve where a
% symmetrised orientation would have shown all its equivalents. Asking for
% them is <fibre.symmetrise.html |symmetrise|>.

plotPDF(f.symmetrise,Miller({1,1,0},{2,1,0},{1,1,1},cs),'linewidth',3,'lineColor','orange')

%%
% Inverse pole figures are by default restricted to the fundamental sector.
% You may use the option |'complete'| to plot the entire sphere.

% an inverse pole figure plot
r = [vector3d(1,1,0),vector3d(2,1,0),vector3d(1,1,1)];
plotIPDF(f.symmetrise,r,'linewidth',3,'lineColor','orange')

%% Defining a Fibre by Directions
%
% Alternatively, a fibre can also be defined by a pair of a crystal and a
% specimen direction. In this case it consists of all orientations that
% align the crystal direction with the specimen direction. As an example,
% the following fibre contains all orientations for which the c-axis
% $[001]$ is parallel to the specimen Z axis.

f = fibre(Miller(0,0,1,cs,'uvw'),vector3d.Z)

plot(f,'linecolor','gold','linewidth',4,'project2FundamentalRegion','axisAngle')


%%
% If both directions are |Miller| variables, the fibre contains all
% misorientations that bring the two crystal directions into alignment.
%
% Finally, a fibre can be defined by an initial orientation |ori1| and a
% direction |h|, i.e., all orientations |ori| of this fibre satisfy
%
%   ori * h = ori1 * h
%
% The following code defines a fibre that passes through the cube
% orientation and rotates about the $[111]$ axis.

f = fibre(ori1,Miller(1,1,1,cs,'uvw'))

plot(f,'linecolor','darkred','linewidth',4,'project2FundamentalRegion','axisAngle')

%% Predefined Fibres
%
% The fibres of rolling texture have names, as the components do - alpha,
% beta, gamma, epsilon, eta, tau and theta - and MTEX has them built in.

ss = specimenSymmetry('orthorhombic');
beta = fibre.beta(cs,ss,'full')

%%
% An overview of all of them, for cubic crystal and orthorhombic specimen
% symmetry:

plot(fibre.alpha(cs,ss,'full'),'linewidth',3,'lineColor',ind2color(1),'DisplayName','alpha')
hold on
plot(fibre.beta(cs,ss,'full'),'linewidth',3,'lineColor',ind2color(2),'DisplayName','beta')
plot(fibre.gamma(cs,ss,'full'),'linewidth',3,'lineColor',ind2color(3),'DisplayName','gamma')
plot(fibre.epsilon(cs,ss,'full'),'linewidth',3,'lineColor',ind2color(4),'DisplayName','epsilon')
plot(fibre.eta(cs,ss,'full'),'linewidth',3,'lineColor',ind2color(5),'DisplayName','eta')
plot(fibre.tau(cs,ss,'full'),'linewidth',3,'lineColor',ind2color(6),'DisplayName','tau')
plot(fibre.theta(cs,ss,'full'),'linewidth',3,'lineColor',ind2color(7),'DisplayName','theta')
hold off
legend('Location','best')

%% Fibre ODFs
%
% A fibre is a curve of zero volume, and a real texture is a spread around
% one. <fibreODF.html |fibreODF|> turns the curve into a density with a
% given halfwidth, which is what a measurement is fitted against.

odf = fibreODF(beta,'halfwidth',10*degree)

% and plot it in 3d
plot3d(odf)

% this adds the fibre to the plots
hold on
plot(beta.symmetrise,'lineColor','b','linewidth',4)
hold off

%% An ODF Along a Fibre
%
% An ODF can also be evaluated along a fibre and plotted as a curve, here
% the beta fibre ODF read along the eta fibre.

plot(odf,fibre.eta(cs,ss),'linewidth',2)


%% The Volume Around a Fibre
%
% <SO3Fun.volume.html |volume|> measures how much of an ODF lies within a
% tube of given radius about a fibre - the number quoted when a texture is
% reported as "so many percent beta fibre".

100 * volume(odf,beta,5*degree)

%%
% 58 percent of this ODF lies within 5 degree of the fibre it was built on,
% and within 10 degree it is the whole of it, to the precision printed.

100 * volume(odf,beta,10*degree)

%% Next
%
% Fibres of plain rotations, without a crystal symmetry, are
% <RotationFibre.html Fibres>. Fibre ODFs and the rest of the model textures
% are <FibreODFs.html Fibre ODFs>.
