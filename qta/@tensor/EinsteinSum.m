function T = EinsteinSum(T1,dimT1,T2,dimT2,varargin)
% tensor multiplication according to Einstein summation
%
%% Description
% This function computes a tensor product according to Einstein summation
%
%% Syntax
% C = mtimesT(E,[1 -1 2 -2],v,-1,v,-2) % 
%
%% Input
%  T1,T2 - @tensor
%  dimT1 - 
%  dimT2 - 
%
%% Output
%  T - @tensor
%
%% See also
%

% convert input
if nargin < 3
  M2 = [];
  dimT2 = [];
elseif isa(T2,'double')
  M2 = T2;
elseif isa(T2,'tensor') 
  M2 = T2.M;
elseif isa(T2,'quaternion')
  M2 = matrix(T2);
elseif isa(T2,'vector3d')
  M2 = double(T2);
  M2 = permute(M2,[3 1 2]);
end

% compute size T2
sT2 = ones(1,length(dimT2));
sT2(1:ndims(M2)) = size(M2);

% check for equals negative values in dimT1
[a,b] = findFirstDouble(dimT1);
if ~isempty(a)
  T1.M = innerSum(T1.M,a,b);
  T1.rank = T1.rank - 2;
  dimT1([a,b]) = [];
  T = EinsteinSum(T1,dimT1,M2,dimT2,varargin{:});
  return
end

% check for equals negative values in dimT2
[a,b] = findFirstDouble(dimT2);
if ~isempty(a)
  M2 = innerSum(M2,a,b);
  dimT2([a,b]) = [];
  T = EinsteinSum(T1,dimT1,M2,dimT2,varargin{:});
  return
end

% check for equals negative values in dimT1 and dimT2
[a,b] = findFirstDouble([dimT1,dimT2]);

if ~isempty(a)
  b = b - length(dimT1);
  T1 = mtimesT(T1,a,M2,[b length(sT2)+1]);  
  dimT1(a) = [];
  dimT2(b) = [];  
  T1.rank = T1.rank + length(dimT2);
  T = EinsteinSum(T1,[dimT1 dimT2],varargin{:});
  return
end

% join matrix 1 and matrix 2
if ~isempty(M2)
  T1.M = reshape(T1.M(:)*M2(:).',[size(T1),sT2]);
  T1.rank = T1.rank + length(dimT2);
  T = EinsteinSum(T1,[dimT1 dimT2],varargin{:});
  return
end

% reorder dimension
order = 1:max(T1.rank,ndims(T1.M));
order(1:length(dimT1)) = dimT1;

try
  T1.M = ipermute(T1.M,order);
catch
  error(['Bad indice! Positive indice has to be a permutation of the numbers: ' num2str(1:ndims(T1.M))])
end
T = T1;
T.properties.name = [];


end

function [a,b] = findFirstDouble(x)

d = bsxfun(@minus,x,x') == 0 & bsxfun(@times,x<0,x'<0);
d = d & ~eye(size(d));
[b,a] = find(d,1);
 
end

function M = innerSum(M,a,b)

% make a,b the first two dimensions
order = 1:max([ndims(M) a b]);
order([a b]) = [];
order = [a b order];
M = permute(M,order);

% extract diagonal with respect to first two dimensions
s = ones(1,max([a,b,ndims(M)]));
s(1:ndims(M)) = size(M);
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
s(:) = 1;
s(1:ndims(M)) = size(M);
s([a b]) = [];
M = reshape(M,[s 1 1]);

end

