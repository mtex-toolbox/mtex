%% Qudarature
%
%%
%

fun = @(v) v.x .* v.y;

sF = S2FunHarmonic.quadrature(fun)

surf(sF)

