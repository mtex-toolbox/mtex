%% Standard Orientations
%
%%

CS = crystalSymmetry('m-3m');
SS = specimenSymmetry('orthorhombic');
setMTEXpref('xAxisDirection','north');
setMTEXpref('zAxisDirection','outofPlane');


%% some stadanrd orientations

components = [...
  orientation.goss(CS,SS),...
  orientation.brass(CS,SS),...
  orientation.cube(CS,SS),...
  orientation.cubeND22(CS,SS),...
  orientation.cubeND45(CS,SS),...
  orientation.cubeRD(CS,SS),...
  orientation.copper(CS,SS),...
  orientation.PLage(CS,SS),...
  orientation.QLage(CS,SS),...
  ];

%% 3d Euler angle space

for i = 1:length(components)
  plot(components(i),'bunge','MarkerSize',10,'filled','DisplayName',round2Miller(components(i),'LaTex'))
  hold on
end
legend('show','interpreter','LaTeX','location','southoutside','numColumns',3,'FontSize',1.2*getMTEXpref('FontSize'));
hold off

%% 2d phi2 sections

figure
for i = 1:length(components)
  plotSection(components(i),'add2all','DisplayName',round2Miller(components(i),'LaTex'))
end

legend('show','interpreter','LaTeX','location','southeast','FontSize',1.2*getMTEXpref('FontSize'));

% saveFigure('componentsSections.png')

%% 3d axis angle space

close all
figure
for i = 1:length(components)
  hold on
  plot(components(i),'axisAngle','MarkerSize',10,'filled','DisplayName',round2Miller(components(i),'LaTex'))
  axis off
end
legend('show','interpreter','LaTeX','location','southoutside','numColumns',3,'FontSize',1.2*getMTEXpref('FontSize'));

%% pole figures

h = Miller({1,0,0},{1,1,0},{1,1,1},{3,1,1},CS);

for i = 1:length(components)
  plotPDF(components(i),h,'MarkerSize',10,'filled','DisplayName',round2Miller(components(i),'LaTex'))
  hold on
end

hold off

legend('show','interpreter','LaTeX','location','northeast','numColumns',2,'FontSize',1.2*getMTEXpref('FontSize'));

%% inverse pole figures

r = [vector3d.X,vector3d.Y,vector3d.Z];

for i = 1:length(components)
  plotIPDF(components(i),r,'MarkerSize',(12-i)^1.5,'filled','DisplayName',round2Miller(components(i),'LaTex'))
  hold on
end

hold off

legend('show','interpreter','LaTeX','location','northeast','numColumns',2,'FontSize',1.2*getMTEXpref('FontSize'));


%%


odf = unimodalODF(components(3),'halfwidth',7.5*degree)

plotPDF(odf,h)
hold on
plotPDF(odf,h,'contour','lineColor','k','linewidth',2)
hold off

%%

plotIPDF(odf,r)
hold on
plotIPDF(odf,r,'contour','lineColor','k','linewidth',2)
hold off

%%

plotSection(odf)

hold on
plotSection(odf,'contour','lineColor','k','linewidth',2)

for i = 1:length(components)

  plotSection(components(i),'MarkerSize',10,'filled','DisplayName',round2Miller(components(i),'LaTex'))
  
end

hold off
