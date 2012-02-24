%% Analyzing Single Grains
% Explanation how to extract and work single grains from EBSD data
%
%
%% Open in Editor
%
%% Contents
%
%% 
%

mtexdata aachen
plotx2east

%%
%

grains = calcGrains(ebsd({'fe','mg'}),'threshold',10*degree)

%%

plot(grains)

p = ginput(1)

%%
p = [225  135];

%%

g = findByLocation(grains,p)
plot(get(g,'EBSD'),'property','mis2mean')


%%

%l = ginput(2)

% l = [120,100.2; 140 100.2];
figure
plot(get(g,'EBSD'),'property','mis2mean','colorcoding','angle')
hold on
text(l(1,1),l(1,2),'a')
line(l(:,1),l(:,2),'color','r','linewidth',2)

%%
% o = 
o = spatialProfile(g,l,'angle')




%%
