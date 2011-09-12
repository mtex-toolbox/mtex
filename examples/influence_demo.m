%% MTEX - Influence of Threshold angle
%
%
% 
% 

%% Open in Editor
%

%% Load sample EBSD data set

mtexdata aachen

plotx2east


%% Estimate ODF with different threshold angles

angles = [5 10 15 20 30 45];

sizes = 2.^(0:ceil(log(numel(ebsd))./log(2)));

for k=1:numel(angles)  
  
  % reconstruct grains with different threshold angels
  grains = calcGrains(ebsd,'angle', angles(k)*degree,'silent');
  
  % compute grain size
  gz(:,k) = histc(grainSize(grains),sizes);
  
end


%%
% and plot it

bar(log(gz))
