%% 3d Grains (The Class [[Grain3d_index.html,Grain3d]])
% class representing *3d Grains*. inherits methods of @GrainSet
%

mtexdata 3d
grains = calcGrains(ebsd)

%%
%

plot(grains,'translucent',.9)
view(3)