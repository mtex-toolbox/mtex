function T = mtimesT(T,dimT,M,dimM)
% tensor multiplication
%
%% Description
% This function multiplies a tensor with some rotation matrix or direction,
% i.e., it computes T_ijkl M_jn, where the dimensions of j and n can be
% specified.
%
%% Syntax
% T = mtimesT(T,dT,M,[dM rM])
%
%% Input
%  T  - @tensor
%  M  - matrix or vector
%  dT - dimension of T where the multiplication takes place
%  dM - dimension of M where the multiplication takes place
%  rM - dimension of M which replaces the multiplication dimension
%  
%
%% Output
%  T - @tensor
%
%% See also
%

if nargin == 4
  % permute M such that the first dimension is the replacement dimension
  % dimM(2) and second dimension is the summation dimension dimM(1)
  order = 1:ndims(M);
  order(dimM(dimM<=ndims(M))) = [];
  order = [fliplr(dimM) order];
  M = permute(M,order);
end

% permute the first rank(T) dimensions of the tensor such that dimT becomes
% the first dimension.
order = 1:ndims(T.M);
order(1:T.rank) = circshift(order(1:T.rank)',1-dimT)';
T.M = permute(T.M,order);

% squeeze the dimensions 2:rank(T) to a single dimension
s = size(T.M);
shape = [s(1),prod(s(2:T.rank)),s((T.rank+1):end)];
T.M = reshape(T.M,shape);

% multiply T.M along the first dimension with the second dimension of M
T.M = mtimesx(M,T.M);

% take the reshape back
ss = size(T.M);
T.M = reshape(T.M,[size(M,1) s(2:T.rank) ss(3:end)]);

% take the reordering back
iorder = 1:ndims(T.M);
iorder(1:length(order)) = order;

T.M = ipermute(T.M,iorder);

end

