function f = example(varargin)
% Construct the gradient from the dubna data set as example for an 
% S2VectorFieldHarmonic.

g = S2VectorFieldHarmonic.example;
f = S2VectorFieldHandle(@(v) g.eval(v));


end