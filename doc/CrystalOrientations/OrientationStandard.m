%% Standard Orientations
%
%%
% Rolling, drawing and recrystallisation produce the same few orientations
% again and again, and those have names - Cube, Goss, Brass, Copper. Naming
% a component is how a texture is described in one sentence, and MTEX has
% the standard ones built in, so a measured texture can be compared against
% them directly.
%
% The predefined orientations are
%
% * Cube, CubeND22, CubeND45, CubeRD
% * Goss, invGoss
% * Copper, Copper2
% * SR, SR2, SR3, SR4
% * Brass, Brass2
% * PLage, PLage2, QLage, QLage2, QLage3, QLage4
%
% For visualization we fix a generic cubic crystal symmetry and
% orthorhombic specimen symmetry

cs = crystalSymmetry('m-3m');
ss = specimenSymmetry('orthorhombic');

% the standard components are defined relative to the rolling frame -
% RD to the north, TD to the west and ND out of the page
specimenFrame.rolling.makeDefault

%%
% and select a subset of the above predefined orientations

components = [...
  orientation.goss(cs,ss),...
  orientation.brass(cs,ss),...
  orientation.cube(cs,ss),...
  orientation.cubeND22(cs,ss),...
  orientation.cubeND45(cs,ss),...
  orientation.cubeRD(cs,ss),...
  orientation.copper(cs,ss),...
  orientation.PLage(cs,ss),...
  orientation.QLage(cs,ss),...
  ];

%%
% Each component is named in the legends below by the lattice plane and
% direction it stands for, as $(hkl)[uvw]$ - the plane facing the sheet
% normal and the direction along the rolling direction, which is what
% <orientation.byMiller.html |orientation.byMiller|> takes.
%
%% Three Dimensional Euler Angle Space
%
% The first view puts every component at its three Bunge Euler angles.

close all
for i = 1:length(components)
  plot(components(i),'bunge','MarkerSize',10,'MarkerColor', ind2color(i),...
    'DisplayName',round2Miller(components(i),'LaTex'))
  hold on
end
legend('show','interpreter','LaTeX','location','southoutside','numColumns',3,'FontSize',1.2*getMTEXpref('FontSize'));
hold off

%% Two Dimensional phi2 Sections
%
% The classical way of showing the same thing on paper: sections of fixed
% $\varphi_2$, in which the rolling components line up in recognisable
% patterns, see <EulerAngleSections.html Euler Angle Sections>.

close all
for i = 1:length(components)
  plotSection(components(i), 'add2all', 'MarkerColor', ind2color(i),...
    'DisplayName', round2Miller(components(i),'LaTex'))
end

legend('show','interpreter','LaTeX','location','southeast','FontSize',1.2*getMTEXpref('FontSize'));

%% Three Dimensional Axis Angle Space
%
% In axis angle space the components sit inside the fundamental region of
% the cubic-orthorhombic pair, see
% <OrientationFundamentalRegion.html Fundamental Region>.

close all
for i = 1:length(components)
  hold on
  plot(components(i),'axisAngle','MarkerSize',10,'MarkerColor', ind2color(i),...
    'DisplayName',round2Miller(components(i),'LaTex'))
  axis off
end
legend('show','interpreter','LaTeX','location','southoutside','numColumns',3,'FontSize',1.2*getMTEXpref('FontSize'));

%% Pole Figures
%
% Where each component puts the major lattice planes. This is the view a
% measured pole figure is compared against - Goss has a $(110)$ pole in the
% centre, since its $(011)$ plane faces the sheet normal, and Cube has its
% $(100)$ poles in the centre and on the two axes of the rim.

h = Miller({1,0,0},{1,1,0},{1,1,1},{3,1,1},cs);

close all
for i = 1:length(components)
  plotPDF(components(i),h,'MarkerSize',10,'MarkerColor', ind2color(i),...
    'DisplayName',round2Miller(components(i),'LaTex'))
  hold on
end
hold off

legend('show','interpreter','LaTeX','location','northeast','numColumns',2,'FontSize',1.2*getMTEXpref('FontSize'));

%% Inverse Pole Figures
%
% The same components seen from the specimen side: which crystal direction
% lies along X, Y and Z. The markers are drawn in decreasing size so that
% components falling on the same spot stay visible.

r = [vector3d.X,vector3d.Y,vector3d.Z];

close all
for i = 1:length(components)
  plotIPDF(components(i),r,'MarkerSize',(12-i)^1.5,'MarkerColor', ind2color(i),...
    'DisplayName',round2Miller(components(i),'LaTex'))
  hold on
end
hold off

legend('show','interpreter','LaTeX','location','northeast','numColumns',2,'FontSize',1.2*getMTEXpref('FontSize'));


%% From a Component to a Model Texture
%
% A named component is a single orientation, and a real texture is a spread
% around one. Giving the component a halfwidth turns it into a model ODF,
% which is what the measured data is actually fitted against, see
% <ODFModeling.html Modeling ODFs>.

odf = unimodalODF(components(3),'halfwidth',7.5*degree)

plotPDF(odf,h)
hold on
plotPDF(odf,h,'contour','lineColor','k','linewidth',2)
hold off

%%
% What was a single point is now a spread about seven degree wide. The same
% in the inverse pole figures,

plotIPDF(odf,r)
hold on
plotIPDF(odf,r,'contour','lineColor','k','linewidth',2)
hold off

%%
% and in phi2 sections, with all the components drawn on top so it is
% visible which one the model was built around.

plotSection(odf)

hold on
plotSection(odf,'contour','lineColor','k','linewidth',2)

for i = 1:length(components)

  plotSection(components(i),'MarkerSize',10,'filled','DisplayName',round2Miller(components(i),'LaTex'))
  
end

hold off
