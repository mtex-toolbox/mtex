%% EBSD Simulation
%
%%
% A method that measures something from a map can only be checked against a
% map whose answer is known in advance. That is what
% <simulateEBSD.simulateEBSD.html |simulateEBSD|> is for: it builds a map
% one feature at a time - a uniform grain, a chosen amount of noise, a low
% angle boundary of a chosen misorientation, an orientation gradient - so
% that a denoising filter, a GND or a WBV computation can be run on data
% whose true content is known.
%
% It builds a single grain. An arrangement of many grains is better made
% with the <NeperInterface.html neper interface>.
%
%% The object and its defaults
%
% Everything is set on one object, which starts with a 100 by 100 grid of
% unit step size and essentially no noise.

eS = simulateEBSD

%% A uniform grain
%
% Set the size, the phase and the orientation, and |makeMap| turns them
% into an EBSD variable in |eS.EBSDsim|.

eS.xdim = 200;

eS.CS = crystalSymmetry('mmm','Mineral','Kryptonite');
eS.ori0 = orientation.byEuler([0,pi/4,0]*degree,eS.CS);

eS.makeMap;

plot(eS.EBSDsim, eS.EBSDsim.orientations)

%%
% One colour, as it should be - every pixel carries |ori0| exactly. This is
% the blank canvas the features below are added to.
%
%% Adding noise
%
% The noise is described by the distribution of the misorientation angle it
% adds, either lognormal or uniform, and by its maximum.

eS.noiseFun = 'logn';
eS.noiseMax = 2*degree;

% update the orientation
eS.addnoise

plot(eS.EBSDsim,angle(eS.ori0,eS.EBSDsim.orientations)/degree)
mtexColorbar

%%
% Plotting the deviation from |ori0| rather than the orientation itself
% shows what was added. Most pixels moved by less than a tenth of a degree
% and a few reach the 2° that was asked for as the maximum, which is what a
% lognormal distribution looks like: many small values and a long tail. The
% map now looks like a real measurement of a perfect crystal.
%
%% A low angle boundary
%
% A feature is given by an axis in specimen coordinates and a
% misorientation angle. |addFeature_singleStep| splits the map in two and
% rotates one half against the other by that misorientation.

eS.axS = yvector;
eS.mori_angle = 3*degree;

eS.addFeature_singleStep;

%%
% Every |addFeature_| call works on the orientations that are already
% there, so features accumulate - the boundary is added to the noisy map,
% not to a fresh one.

newMtexFigure('layout',[2,1])

plot(eS.EBSDsim,angle(eS.ori0,eS.EBSDsim.orientations)/degree)

% and compute grains so we can inspect the boundary
grain = eS.EBSDsim.calcGrains('angle',[1 10]*degree);
nextAxis
plot(grain); hold on
plot(grain.innerBoundary,grain.innerBoundary.misorientation.angle/degree,'linewidth',3)
hold off
setColorRange([2.75 3.25])
mtexColorbar

%%
% The left map shows the two halves, one still at |ori0| and one 3° away
% from it. On the right the segmentation was run with a lower threshold of
% 1°, which turns the step into a subgrain boundary, and its misorientation
% is plotted along it. The colour range is deliberately narrow, 2.75° to
% 3.25°. Over its 171 segments the boundary averages 2.97°, the 3° it was
% given, spread from 2.0° to 3.3° by the noise that was added before it.
%
%% Starting over
%
% |makeMap| resets the map to a uniform grain again, ready for a different
% experiment.

eS.makeMap
