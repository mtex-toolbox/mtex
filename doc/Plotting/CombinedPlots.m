%% Combined Plots
%
%%
% Most figures worth publishing put two things in one picture: measurements
% on top of the function they were fitted to, two data sets in the same
% projection, crystal directions marked on an inverse pole figure. There are
% three ways to do this in MTEX, and they differ in what they do when a
% figure has more than one axis.

plottingConvention.default('y↑→x');

%% Holding a plot
%
% The MATLAB way. <matlab:doc('hold') |hold on|> keeps what is drawn, so the
% next command adds to it rather than replacing it, and |hold off| ends
% that.

close all
plot([2 2],'LineWidth',2)

hold on

plot([1 3],'LineWidth',2)

hold off

%% Two data sets in one projection
%
% Two sets of orientations, one rotated against the other:

% let's simulate some orientation data
cs = crystalSymmetry('-3m');
odf = unimodalODF(orientation.byEuler(0,0,0,cs));
ori = discreteSample(odf,100);
ori_rotated = discreteSample(rotate(odf,rotation.byEuler(60*degree,60*degree,0*degree)),100);

%%
% drawn in axis angle space, the second on top of the first:

scatter(ori,'axisAngle')
hold on % keep plot
scatter(ori_rotated);
hold off % next plot command deletes all plots

%%
% The same comparison in pole figures. Note that the second |plotPDF| does
% not repeat the |'antipodal'| flag - the axes already have it, and what is
% added has to fit the axes it is added to.

h = [Miller(0,0,0,1,cs),Miller(1,0,-1,0,cs)];
plotPDF(ori,h,'antipodal','MarkerSize',4)
hold on
plotPDF(ori_rotated,h,'MarkerSize',4);
hold off

%% Adding to every axis at once
%
% |hold on| adds to the *current* axis. A pole figure figure has one axis
% per lattice plane, so adding markers to all of them means adding them
% several times - unless the plot is told to go into all axes at once, which
% is what |'add2all'| does.

plotPDF(odf,h,'antipodal','contourf','grid')
mtexColorMap white2black

plot(ori,'DisplayName','EBSD 1',...
  'MarkerSize',5,'MarkerColor','b','MarkerEdgeColor','w','add2all')

plot(ori_rotated,'DisplayName','EBSD 2',...
  'MarkerSize',5,'MarkerColor','r','MarkerEdgeColor','k','add2all');

legend('show','location','northeast')

%%
% Each set of orientations went into both pole figures, in one command.
% MTEX projected each of them into each axis according to what that axis
% shows - which is the second thing |'add2all'| does and |hold on| does
% not.
%
% ODF sections work the same way, and here it matters more: there are eight
% axes, and every orientation belongs in the section closest to it.

plot(odf,'sections',8,'contourf','sigma')
mtexColorMap white2black
plot(ori,'MarkerSize',6,'MarkerColor','b','MarkerEdgeColor','w','add2all')
plot(ori_rotated,'MarkerSize',6,'MarkerColor','r','MarkerEdgeColor','k','add2all');

%%
% The markers of the unrotated set gather in the first sections, where the
% contours of the ODF are, and the rotated set appears elsewhere - which is
% the check that the two are really different orientations and not a
% different description of the same ones.

%% Marking crystal directions
%
% An inverse pole figure is a map of crystal directions, so marking the
% important ones on it makes it readable. |'symmetrised'| draws every
% symmetrically equivalent direction, |'labeled'| writes the indices beside
% them.

plotIPDF(odf,xvector,'noLabel');
mtexColorMap white2black

hold on % keep plot
plot(Miller(0,0,0,1,cs),'symmetrised','labeled','backgroundColor','w')
plot(Miller(1,1,-2,0,cs),'symmetrised','labeled','backgroundColor','w')
plot(Miller(0,1,-1,0,cs),'symmetrised','labeled','backgroundColor','w')
plot(Miller(0,1,-1,1,cs),'symmetrised','labeled','backgroundColor','w')
hold off % next plot command deletes all plots

%%
% Now the maximum can be named rather than pointed at: it sits at the
% (0001) pole, which is what a fibre texture about the c axis looks like in
% an inverse pole figure.

%% Different plots side by side
%
% The third case is not overlaying but arranging: several independent plots
% in one figure. Every MTEX plotting command takes |'parent'|, so MATLAB's
% own <matlab:doc('subplot') |subplot|> does the arranging.

% let us import some pole figure data
mtexdata dubna

%%

odf = calcODF(pf)

%%
% Measured, recalculated and difference pole figure, side by side - the
% standard figure for judging a reconstruction, see
% <PoleFigure2ODF.html ODF Estimation>.

figure('position',[50 50 1200 500])

% set position 1 in a 1x3 matrix as the current plotting position
axesPos = subplot(1,3,1);

% plot pole figure 1 at this position
plot(pf({1}),'parent',axesPos)

% set position 2 in a 1x3 matrix as the current plotting position
axesPos = subplot(1,3,2);

% plot the recalculated pole figure at this position
plotPDF(odf,pf{1}.h,'antipodal','parent',axesPos)

% set position 3 in a 1x3 matrix as the current plotting position
axesPos = subplot(1,3,3);

% plot the difference pole figure at this position
plotDiff(odf,pf({1}),'parent',axesPos)

%%
% For a grid of MTEX plots of the same kind there is a better tool than
% |subplot|, which keeps the axes aligned and shares one colorbar between
% them - see <Multiplot.html Multiplot>.
