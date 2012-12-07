function T = EinsteinSum(T1,dimT1,T2,dimT2,varargin)
% tensor multiplication according to Einstein summation
%
%% Description
% This function computes a tensor product according to Einstein summation
%
%% Syntax
% C = EinsteinSum(E,[1 --1 2 --2],v,--1,v,--2) - sumation against dimension ...
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

%% convert input
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
else
  varargin = [{T2,dimT2} varargin];
  M2 = [];
  dimT2 = [];
  
end

% compute size T1 and T2
sT1 = ones(1,length(dimT1));
sT1(1:ndims(T1.M)) = size(T1.M);

rank2 = numel(dimT2);
sT2 = ones(1,rank2);
sT2(1:ndims(M2)) = size(M2);

% overhead
l1 = max(1,prod(sT1(T1.rank+1:end)));
l2 = max(1,prod(sT2(rank2+1:end)));
if l1==1
  ll = l2;
elseif l2 == 1
  ll = l1;
elseif l1 == l2
  ll = l1;
else
  error('Length of the tensors does not fit.');
end

%% check for equals negative values in dimT1
[a,b] = findFirstDouble(dimT1);
if ~isempty(a)
  T1.M = innerSum(T1.M,a,b);
  T1.rank = T1.rank - 2;
  dimT1([a,b]) = [];
  T = EinsteinSum(T1,dimT1,M2,dimT2,varargin{:});
  return
end

%% check for equals negative values in dimT2
[a,b] = findFirstDouble(dimT2);
if ~isempty(a)
  M2 = innerSum(M2,a,b);
  dimT2([a,b]) = [];
  T = EinsteinSum(T1,dimT1,M2,dimT2,varargin{:});
  return
end

%% join matrix 1 and matrix 2
if ~isempty(M2)
  
  % expand T1.M and T2.M such that they fit
  M1 = reshape(T1.M,prod(sT1(1:T1.rank)),1,[]);
  M2 = reshape(M2,1,prod(sT2(1:rank2)),[]);
  
  % expand T1.M and T2.M such that they fit
  T1.M = repmat(M1,[1 size(M2,2) ll/l1]) .* ...
    repmat(M2,[size(M1,1) 1 ll/l2]);
  
  % combine matrices
  T1.M =reshape(T1.M,[sT1(1:T1.rank),sT2(1:rank2),ll]);
      
  % combine rank
  T1.rank = T1.rank + rank2;
  
  % continue computation
  T = EinsteinSum(T1,[dimT1 dimT2],varargin{:});
  return
end

%% reorder dimension
order = 1:max(T1.rank,ndims(T1.M));
order(1:length(dimT1)) = dimT1;

try
  T1.M = ipermute(T1.M,order);
catch
  error(['Bad indice! Positive indice has to be a permutation of the numbers: ' num2str(1:ndims(T1.M))])
end
T = T1;

%% remove name and unit
if hasProperty(T,'name'), T.properties = rmfield(T.properties,'name');end
if hasProperty(T,'unit'), T.properties = rmfield(T.properties,'unit');end
  
if check_option(varargin,'doubleconvention')
  T.doubleConvention = true;
end


varargin = delete_option(varargin,{'doubleconvention','singleconvention','InfoLevel'});

%% extract properties
while ~isempty_cell(varargin)  
  T.properties.(varargin{1}) = varargin{2};
  varargin = varargin(3:end);
end

end

%% ------------- private functions -----------------------

function [a,b] = findFirstDouble(x)

d = bsxfun(@minus,x,x') == 0 & bsxfun(@times,x<0,x'<0);
d = d & ~eye(size(d));
[b,a] = find(d,1);
 
end

%% 
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

