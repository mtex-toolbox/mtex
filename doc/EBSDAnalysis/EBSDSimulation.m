%% EBSD Simulation
%
%%
% Sometimes it is useful to simulate EBSD data with a given noise, e.g. 
% when testing denoising or a given low angle boundary or orientation 
% gradient for testing methods such as GND or WBV for example. 
% <simulateEBSD.simulateEBSD.html|simulateEBSD|> can introduce various 
% boundary geometries and an arbitrary misorientation.
% Current limitations: simulating multi grain arrangement which can be done
% more reasonably using the <NeperInterface.html|neper interface|>.

% In order to simulate a single "grain", we initialize the object, which
% has several properties

eS = simulateEBSD

% Let's change the default size 

eS.xdim = 200;

% and assign an orientation
eS.CS = crystalSymmetry('mmm','Mineral','Kryptonite');
eS.ori0 = orientation.byEuler([0,pi/4,0]*degree,eS.CS);

% next we want to create map from the inital input which can be accessed
% from '.EBSDSim

eS.makeMap;

plot(eS.EBSDsim, eS.EBSDsim.orientations)

% which is indeed not too impressive for now.

%% Adding noise

% Currently noise can be chosen as either with a lognormal or uniform
% misorientation angle distribution

% Let's use lognally distributed noise with a maximum of 2 degree.
eS.noiseFun = 'logn';
eS.noiseMax = 2*degree;

% update the orientiation 
eS.addnoise

plot(eS.EBSDsim,angle(eS.ori0,eS.EBSDsim.orientations)/degree)
mtexColorbar

%% Creating a simple low angle boundary

% now let's create a single boundary with a misorientation defined by 
% an axis in specimen coordinates and an misorientation angle

eS.axS = yvector;
eS.mori_angle = 3*degree;

eS.addFeature_singleStep;
% Note that every time we run 'addFeature_' it is applied on the previous
% orientations!

newMtexFigure('layout',[2,1])

% Now we can plot it
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
% If we want to reset the map and simulate something else
eS.makeMap




