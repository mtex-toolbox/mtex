%% Grain Neighbors
%
%%
% In this section we discuss how to analyze the neighboring relationships
% between grains. While most of this can be done also on the level of grain
% boundaries an local misorientations it is for large data sets sometimes
% useful to consider misorientations between the mean-orientations of
% grains. We shall use the following Magnesium data set of our
% explanations.

% load sample EBSD data set
plottingConvention.default('y↑→x');
mtexdata twins silent
CS = ebsd.CS;

% reconstruct grains
[grains, ebsd] = calcGrains(ebsd,'angle',5*degree);

grains = smoothBoundary(grains,5);

% plot the grains
plot(grains,grains.meanOrientation)

%%
% Central for the analysis of grain to grain relationships is the function 
% <grain2d.neighbors.html |grains.neighbours|>. It return a list of pairs
% of neighboring grain ids. Each row of the list contains the ids of two
% neighboring grains. In the following lines choose the row number 188 and
% outline the corresponding grains

pairs = grains('indexed').neighbors;

hold on
plot(grains(pairs(188,:)).boundary,'LineWidth',4,'linecolor','b')
hold off

%%
% In order to compute the misorientation between these two grains we can do

mori = inv(grains(pairs(188,1)).meanOrientation) * grains(pairs(188,2)).meanOrientation

%%
% This can be generalized to compute the misorientations between
% neighboring grains using

mori = inv(grains(pairs(:,1)).meanOrientation) .* grains(pairs(:,2)).meanOrientation

close all
histogram(mori.angle./degree)
xlabel('misorientation angle')

%%
% We observe a high peak at about 85 degree. This angle corresponds to
% twinning. In Magnesium the twinning orientation relationship is given by

twinning = orientation.map(Miller(0,1,-1,-2,CS),Miller(0,-1,1,-2,CS),...
  Miller(2,-1,-1,0,CS),Miller(2,-1,-1,0,CS))


%%
% In order to determine the percentage of twining pairs we do 

% which of the pairs are twinning
isTwinning = angle(mori,twinning) < 3*degree;

% percentage of twinning pairs
100 * sum(isTwinning) / length(isTwinning)

%%
% It is important to understand that the list returned by
% |grains.neighbours| contains only pairs such that both grains are
% contained in |grains|. This allows the syntax |grains('phaseName')| to
% extract only neighbor relation ships within one phase.
%%
% In some case, e.g. if we ask for all neighboring grains to a given
% grains, it is useful to replace this constraint by the condition that at
% least one grain should by part of |grains|. This can be accomplished by
% the option |'full'|.

% get all pairs containing grain 92
pairs = grains(92).neighbors('full');

% remove center grain 83 from this list
pairs(pairs == 92) = [];

plot(grains,grains.meanOrientation,'micronbar','off')
hold on
plot(grains(pairs),'FaceColor','black','FaceAlpha',0.5)
hold on
plot(grains(92).boundary,'lineColor','white','lineWidth',3)
hold off

%#ok<*NASGU> 
%#ok<*NOPTS>
%#ok<*MINV>