function vals = evalSphericalHarmonics(v,deg)
% the spherical harmonics of degree deg, deg-2, ..., mod(deg,2) on v

% the coefficients n^2+1 to (n+1)^2 belong to degree n
isDeg = repelem(mod(0:deg,2) == mod(deg,2),1:2:2*deg+1);
dim = (deg + 1) * (deg + 2) / 2;
M = full(sparse(1:dim,find(isDeg),ones(dim,1)));

Y = S2FunHarmonic(M');
vals = Y.eval(v);

end
