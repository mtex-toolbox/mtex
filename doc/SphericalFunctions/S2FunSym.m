%% S2FunHarmonicSym
%
% The class |S2FunHarmonicSym| is an extension of the class
% |@S2FunHarmonic| representing symmetric spherical functions.
%
%% Defining a S2FunHarmonic
%
%%
% *Definition via symmetrisation*
%
% The simplest way to define a symmetric spherical function is through the
% symmetrisation of an ordinary |@S2FunHarmonic|.

sF = S2Fun.smiley
ss = specimenSymmetry('222');

sFs1 = symmetrise(sF, ss);

%%
% * this symmetrises the function and gives back the result with the
% symmetry attached

plotx2north
plot(sFs1,'complete','upper')

%%
% * Note that only the important part with respect to the symmetry is
% plotted
% * you can plot the full sphere using the argument |'complete'|

%%
% *Definition via function handle*
%
% If you have a function handle for the function you could create a
% |@S2FunHarmonicSym| via quadrature. At first lets define a symmetry and a
% function handle which takes |@vector3d| as an argument and returns
% double:

f = @(v) 0.1*(v.theta+sin(8*v.x).*sin(8*v.y));
cs = crystalSymmetry('6/m');

%% 
% Now you can call the quadrature command to get |sFs2| of type
% |@S2FunHarmonicSym|

sFs2 = S2FunHarmonicSym.quadrature(f, cs)

%% Visualization
% The plot commands for a |S2FunHarmonicSym| by default plot the function
% only on the fundamental Sector of the symmetry. E.g. the default
% |plot|-command look as follows

plot(sFs1);

%%
% Another Example is the contour plot

contour(sFs2);
