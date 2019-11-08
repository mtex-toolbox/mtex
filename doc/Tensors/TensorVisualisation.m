%% Tensor Visualization
%
%% TODO
% Please extend this chapter
%
%% Visualization
% The default plot for each tensor is its directional magnitude, i.e. for
% each direction x it is plotted Q(x) = T_ijkl x_i x_j x_k x_l

setMTEXpref('defaultColorMap',blue2redColorMap);


C = stiffnessTensor.rand

plot(C,'complete','upper')
%%
% set back the default color map.

setMTEXpref('defaultColorMap',WhiteJetColorMap)


%%
% There are more specialized visualization possibilities for specific
% tensors, e.g., for the elasticity tensor. See section
% <Elasticity.html Elasticity>.