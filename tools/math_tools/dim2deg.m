function l = dim2deg(dim)
% dimension to harmonic degree of Wiegner D functions

l = 0;
while deg2dim(l+2) <= dim, l = l + 1;end