function vals = eval_spherical_harmonics(v, deg)
% eval all spherical harmonics of degree deg, deg-2 , ..., mod(deg,2) on v

% get the number of functions corresponding to the degree
dim = (deg + 1) * (deg + 2) / 2;

% the dimensions of the harmonic spaces is 2n+1 for degree n
% the following vector marks only the even spherical harmonics
% we can mark the odd spherical harmonics by negating it
marker = [
    1 ...
    0 0 0 ... 
    1 1 1 1 1 ...
    0 0 0 0 0 0 0 ...
    1 1 1 1 1 1 1 1 1 ...
    0 0 0 0 0 0 0 0 0 0 0 ...
    1 1 1 1 1 1 1 1 1 1 1 1 1]';

% even case 
if mod(deg, 2) == 0
    [ind_even, ~] = find(marker);
    M = full(sparse(1:dim, ind_even(1:dim), ones(dim, 1)));
% odd case
else
    [ind_odd, ~] = find(~marker);
    M = full(sparse(1:dim, ind_odd(1:dim), ones(dim, 1)));
end

Y = S2FunHarmonic(M');

vals = Y.eval(v);

end
