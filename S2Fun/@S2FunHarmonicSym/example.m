function f = example(varargin)
% Construct the smiley function as example for an S2FunHarmonic.

s = specimenSymmetry.default;
f = S2FunHarmonicSym(S2Fun.smiley,s);

end