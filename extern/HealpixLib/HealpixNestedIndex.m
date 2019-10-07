% I = HealpixNestedIndex(n, pn)
% Parameters
% n  : resolution of the grid (N_side)
% pn : index number

function I = HealpixNestedIndex(n, pn)

n_phi = 4;

n2 = n^2;
f = fix(pn / n2);
pnd = mod(pn, n2);

x = 0;
y = 0;

for b = 0:14
    if bitand(pnd, bitshift(1, 2 * b)) ~= 0
        x = x + bitshift(1, b);
    end
    if bitand(pnd, bitshift(1, 2 * b + 1)) ~= 0
        y = y + bitshift(1, b);
    end
end

% 論文より
%f_row = fix(f / n_phi);
%f1 = f_row + 2;
%f2 = 2 * mod(f, n_phi) - mod(f_row, 2) + 1;

% Healpixソースコードより
f1l = [ 2,2,2,2,3,3,3,3,4,4,4,4 ];
f2l = [ 1,3,5,7,0,2,4,6,1,3,5,7 ];
f1 = f1l(f + 1);
f2 = f2l(f + 1);

v = x + y;
h = x - y;

i = f1 * n - v - 1;

if i < n
    s = 1;
    nr = i;
elseif 3 * n < i
    s = 1;
    nr = 4 * n - i;
else
    s = mod(i - n + 1, 2);
    nr = n;
end

j = (f2 * nr + h + s) / 2;

if j > 4 * n
    j = j - 4 * n;
end
if j < 1
    j = j + 4 * n;
end

I = [i j];
