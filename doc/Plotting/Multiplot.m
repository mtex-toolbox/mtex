%% Multiplot
%
%%
mtexFig = newMtexFigure('layout',[2,3]);

plot(xvector,'upper')

nextAxis

plot(zvector,'upper')

nextAxis(2,3)

plot(vector3d.rand(200),'upper')

nextAxis(2,3)

plot(xvector)

nextAxis(2,1)

plot(crystalSymmetry('432'))