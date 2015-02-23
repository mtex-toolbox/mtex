%% CSL Boundaries
% Explains how to analyze CSL grain boundaries
%
%% Open in Editor
%
%% Contents
%
%% Data import and grain detection
%
% Lets import some iron data and segment grains within the data set.

CS = crystalSymmetry('cubic','mineral','iron')
ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','CNR.txt'),CS,...
  'interface','generic',...
  'ColumnNames',{'phase','x','y','phi1','Phi','phi2','IQ','CI','error'})

% grain segementation
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'))

% grain smoothing
grains = smooth(grains,2) 

% plot the result
plot(grains,grains.meanOrientation)

%%

plot(ebsd,ebsd.prop.iq,'figSize','large')
mtexColorMap black2white

%%

gB = grains.boundary('iron','iron')

hold on
plot(grains.boundary)
hold off

%%

hold on
gB3 = gB(angle(gB.misorientation,CSL(3))<3*degree);
plot(gB3,'lineColor','b','linewidth',2,'DisplayName','CSL 3')
hold off

%%

[mergedGrains,parentIds] = merge(grains,gB3);

hold on
plot(mergedGrains.boundary,'linecolor','g','linewidth',2)



%%

delta = 5*degree;
gB3 = gB(gB.isTwinning(CSL(3),delta))
gB5 = gB(gB.isTwinning(CSL(5),delta))
gB7 = gB(gB.isTwinning(CSL(7),delta))
gB9 = gB(gB.isTwinning(CSL(9),delta))
gB11 = gB(gB.isTwinning(CSL(11),delta))


%%

hold on
plot(gB3,'lineColor','g','linewidth',2,'DisplayName','CSL 3')
hold on
plot(gB5,'lineColor','b','linewidth',2,'DisplayName','CSL 5')
hold on
plot(gB7,'lineColor','r','linewidth',2,'DisplayName','CSL 7')
hold on
plot(gB9,'lineColor','m','linewidth',2,'DisplayName','CSL 9')
hold on
plot(gB11,'lineColor','c','linewidth',2,'DisplayName','CSL 11')
hold off
