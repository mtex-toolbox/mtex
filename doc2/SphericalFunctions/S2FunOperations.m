%% Operations on Spherical Functions
%
%%
% The idea of |S2Fun| is to calculate with spherical functions similarly as
% Matlab does with vectors and matrices. In order to illustrate this
% consider the following two spherical functions

sF1 = S2Fun.smiley;
sF2 = S2FunHarmonic.unimodal('halfwidth',10*degree)

plot(sF1,'upper')
nextAxis
plot(sF2,'upper')

%% Basic arithmetic operations

plot(15 * sF1 + sF2,'upper')

%%

% addition/subtraction
sF1+sF2; sF1+2;
sF1-sF2; sF2-4;

%%
% multiplication/division
sF1.*sF2; 2.*sF1;
sF1./(sF2+1); 2./sF2; sF2./4;

%%
% power
sF1.^sF2; 2.^sF1; sF2.^4;

%%
% absolute value of a function
abs(sF1);


%%
% *min/max*
%
%%
% calculates the local min/max of a single function
[minvalue, minnodes] = min(sF1);
[maxvalue, maxnodes] = max(sF1);

%%
% * as default |min| or |max| returns the smallest or the biggest value (global optima) with all nodes for which the value is obtained
% * with the option |min(sF1, 'numLocal', n)| the |n| nodes with the belonging biggest or smallest values are returned
% * |min(sF1)| is the same as running <S2Funharmonic.steepestDescent.html |steepestDescent|>|(sF1)|
%%
% min/max of two functions in the pointwise sense
%
min(sF1, sF2);

%%
% * See all options of min/max <S2FunHarmonic.min.html here>

%%
% *Other operations*
%%
% calculate the $L^2$-norm, which is only the $l^2$-norm of the Fourier-coefficients
norm(sF1);

%%
% calculate the mean value of a function
mean(sF1);

%%
% calculate the surface integral of a function
sum(sF1);

%%
% rotate a function
r = rotation.byEuler( [pi/4 0 0]);
rotate(sF1, r);

%%
% symmetrise a given function
cs = crystalSymmetry('6/m');
sFs = symmetrise(sF1, cs);

%%
% * |sFs| is of type <S2FunHarmonicSym.S2FunHarmonicSym.html |S2FunHarmonicSym|>

%%
% *Gradient*
%%
% Calculate the gradient as a function |G| of type
% <S2VectorFieldHarmonic.S2VectorFieldHarmonic.html |S2VectorFieldHarmonic|>
%
G = grad(sF1);

%%
% The direct evaluation of the gradient is faster and returns
% <vector3d.vector3d.html |vector3d|>
nodes = vector3d.rand(100);
grad(sF1, nodes);