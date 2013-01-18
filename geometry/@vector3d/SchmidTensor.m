function m = SchmidTensor(n,b,varargin)
% computes the Schmidt tensor
%
%% Input
%  n - normal vector the the slip or twinning plane
%  b - Burgers vector (slip) or twin shear direction (twinning)
%
%% Output
%  m - Schmid tensor
%
%%
%

n = tensor(n);
b = tensor(b);

m = 0.5*(EinsteinSum(n,1,b,2) + EinsteinSum(n,2,b,1));


end

