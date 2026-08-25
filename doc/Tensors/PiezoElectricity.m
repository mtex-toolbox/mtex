%% The Piezoelectricity Tensor
%
%%
% A piezoelectric crystal polarises when it is squeezed. Which way and how
% strongly depends on the direction of the squeeze, and the rank 3 tensor
% that relates the two is what this page plots and averages.
%
% The example is quartz, whose piezoelectricity is what makes it the crystal
% in an oscillator.

plottingConvention.default('y↑→x');

CS = crystalSymmetry('32', [4.916 4.916 5.4054], 'X||a*', 'Z||c', 'mineral', 'Quartz');

fname = fullfile(mtexDataPath,'tensor', 'Single_RH_quartz_poly.P');

P = tensor.load(fname,CS,'propertyname','piezoelectricity','unit','C/N','DoubleConvention')

%% The magnitude surface
%
% <tensor.plot.html |plot|> shows the directional magnitude - how much
% polarisation results from a stress applied along each direction. By
% default only the part of the sphere that symmetry does not repeat is
% drawn.

% set some colormap well suited for tensor visualisation
setMTEXpref('defaultColorMap',blue2redColorMap);

plot(P)
mtexColorbar

%%
% Red and blue: the sign matters here, unlike in a stiffness tensor. A
% stress along a red direction and one along a blue direction polarise the
% crystal in opposite senses.
%
% |'complete'| draws the whole sphere, where the threefold axis of quartz
% and the alternation of sign are both visible:

close all
plot(P,'complete','smooth','upper')
mtexColorbar

%% As a surface
%
% The same function drawn as a radial surface, the form most standard texts
% use:

close all
surf(P.directionalMagnitude)

%%
% Note what happens to the negative values: the radius cannot be negative,
% so those directions are drawn at their positive magnitude and the surface
% appears to cover itself twice.

%%
% A section through that surface is the classical figure, and for quartz it
% has a closed form. In the plane normal to z:

plotSection(P.directionalMagnitude,vector3d.Z)
xlabel('x')
ylabel('y')
drawNow(gcm)

%%
% Six lobes, from the threefold axis together with the change of sign. The
% plane normal to x instead:

plotSection(P.directionalMagnitude,vector3d.X)
ylabel('y')
zlabel('z')
drawNow(gcm)

%% The average over a polycrystal
%
% A single crystal polarises; whether a rock does depends on whether its
% crystals are aligned. Averaging the tensor over a measured set of
% orientations answers that - here the quartzite of Mainprice, D., Lloyd,
% G.E. and Casey, M. (1993), Individual orientation measurements in quartz
% polycrystals: advantages and limitations for texture and petrophysical
% property determinations, J. of Structural Geology, 15, pp.1169-1187.

fname = fullfile(mtexDataPath,'orientation', 'Tongue_Quartzite_Bunge_Euler');

ori = orientation.load(fname,CS, 'ColumnNames', {'Euler 1' 'Euler 2' 'Euler 3'})

%%
% The averaged tensor, which reproduces the figure on p.1184 of that paper:

Pm = ori.calcTensor(P)

plot(Pm)
mtexColorbar

%%
% Compare the colour range with the single crystal above: the magnitude runs
% to 0.59 where the single crystal reached 2.3, four times weaker.
% Differently oriented crystals polarise in opposing senses and cancel, so a
% piezoelectric effect survives averaging only in proportion to how aligned
% the crystals are - which is why a quartzite is not an oscillator.

setMTEXpref('defaultColorMap',WhiteJetColorMap)
