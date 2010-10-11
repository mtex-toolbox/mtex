function T = EinsteinSum(T1,dimT1,T2,dimT2)
% tensor multiplication according to Einstein summation
%
%% Description
% This function multiplies a tensor with some rotation matrix or direction,
% i.e., it computes T_ijkl M_jn, where the dimensions of j and n can be
% specified.
%
%% Syntax
% T = mtimesT(T1,[],T2,[])
%
%% Input
%  T1,T2 - @tensor
%  dimT1 -
%  dimT2
%
%% Output
%  T - @tensor
%
%% See also
%

% check for equals negative values in dimT1
[a,b] = findFirstDouble(dimT1);
if ~isempty(a)
  T1.M = innerSum(T1.M,a,b);
  T1.rank = T1.rank - 2;
  dimT1([a,b]) = [];
  T = EinsteinSum(T1,dimT1,T2,dimT2);
  return
end

% check for equals negative values in dimT2
[a,b] = findFirstDouble(dimT2);
if ~isempty(a)
  T2.M = innerSum(T2.M,a,b);
  T2.rank = T2.rank - 2;
  dimT2([a,b]) = [];
  T = EinsteinSum(T1,dimT1,T2,dimT2);
  return
end

% check for equals negative values in dimT1 and dimT2
[a,b] = findFirstDouble([dimT1,dimT2]);

if ~isempty(a)
  b = b - length(dimT1);
  T1 = mtimesT(T1,a,T2,[b ndims(T2)+1]);
  dimT1(a) = [];
  dimT2(b) = [];
  T = EinsteinSum(T1,[dimT1 dimT2]);
  return
end

% reorder dimension
order = size(T1.M);


end

function [a,b] = findFirstDouble(x)

d = bsxfun(@minus,x,x') == 0 & bsxfun(@times,x<0,x'<0);
[a,b] = find(d,2);
 
if ~isempty(a)
  b = a(2);
  a = a(1);
end

end

function M = innerSum(M,a,b)

% make a,b the first two dimensions
order = 1:ndims(M);
order([a b]) = [];
order = [a b order];
M = permute(M,order);

% extract diagonal with respect to first two dimensions
s = size(M);
d1 = 1:size(M,1);
d1 = (d1 + size(M,1)*(d1-1));
f = size(M,1)*size(M,2);
d2 = 1:numel(M)/f;
ind = bsxfun(@plus,d1.',(d2-1)*f);

% sum along the diagonal
M = sum(M(ind),1);

% reorder and reshape back
M = reshape(M,[1 1 s(3:end)]);
M = ipermute(M,order);

s = size(M);
s([a b]) = [];
M = reshape(M,s);

end

