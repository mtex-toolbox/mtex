function f = example(varargin)
% Construct example for an S2FunBingham.

Z = [-10 -4 0];
a = rotation.rand(1).*vector3d([xvector yvector zvector]);
f = S2FunBingham(Z,a);

end