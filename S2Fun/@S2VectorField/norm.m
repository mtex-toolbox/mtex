function S2F = norm(vF)
% norm of a spherical vector field as a spherical function
%

S2F = S2FunHandle(@(v) norm(vF.eval(v)));
