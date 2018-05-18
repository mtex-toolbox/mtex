function T = mpower(v,n)
% n-th dyadic product

args = [repcell(v,1,n);vec2cell(1:n)];

T = EinsteinSum(args{:});
