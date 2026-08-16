%% Symmetric Spherical Functions
%
% In several applications spherical functions are symmetric with respect to
% some symmetry group. Typically examples are inverse pole figures or
% properties of single crystals. In MTEX one can ensure symmetry properties
% of spherical functions by defining them as variables of type
% |@S2FunHarmonicSym|. 
%
%% Defining a S2FunHarmonic
%
%%
% *Definition via symmetrisation*
%
% The simplest way to define a symmetric spherical function is through the
% symmetrisation of an ordinary |@S2FunHarmonic|.

% the original function 
% the smiley reads right with y up
plottingConvention.default('y↑→x');
sF = S2Fun.smiley;

% the symmetry
ss = specimenSymmetry('222',sF.how2plot);

% attach the symmetry to the function
sFs1 = S2FunHarmonicSym(sF, ss);

% and enforce it
sFs1 = sFs1.symmetrise

plot(sFs1)

%%
% Note that symmetry function are by default only plotted within their
% representative sector, as it is typical for inverse pole figures. In
% order to visualize the full sphere we have to use the option
% |'complete'|.

plot(sFs1,'complete','upper')

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

contour(sFs2,'linewidth',2);
mtexColorMap parula