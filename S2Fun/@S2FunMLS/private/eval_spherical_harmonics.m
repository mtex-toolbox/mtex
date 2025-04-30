function vals = eval_spherical_harmonics(v, deg)
% eval the spherical harmonics of degree deg, deg-2 , ..., mod(deg,2) on v

% get the number of functions corresponding to the degree
dim = (deg + 1) * (deg + 2) / 2;

% the dimensions of the harmonic spaces is 2n+1 for degree n
% the following vector marks only the even spherical harmonics
marker = repelem( (1+(-1).^(0:deg)) / 2, (1:2:(2*deg+1)) );

% even case 
if mod(deg, 2) == 0
  % get indice of the even degrees
  ind_even = find(marker);
  M = full(sparse(1:dim, ind_even(1:dim), ones(dim, 1)));
  % odd case
else
  % get indice of the odd degrees by negating marker
  ind_odd = find(~marker);
  M = full(sparse(1:dim, ind_odd, ones(dim, 1)));
end

Y = S2FunHarmonic(M'); 

vals = Y.eval(v);

end