function T = EinsteinSum(varargin)
% tensor multiplication according to Einstein summation convention
%
% Description
% This function computes a tensor product according to Einstein summation
% convention. Every summation index has to appear exactly twice, either in
% two of the tensors or twice within one tensor. Tensor arrays are
% multiplied elementwise, singleton array dimensions expand.
%
% Syntax
%   % summation against dimension 1 and 2
%   C = EinsteinSum(E,[1 -1 2 -2],v,-1,v,-2)
%
%   eps = EinsteinSum(C,[-1 1 -2 2],sigma,[-1 -2])
%
% Input
%  T1,T2 - @tensor, @vector3d, @rotation, double
%  dimT1 - vector of indices giving the summation order in tensor 1
%  dimT2 - vector of indices giving the summation order in tensor 2
%
% Output
%  T - @tensor
%
% Flags
%  keepClass - the result keeps the class of T1
%
% See also
%

T = varargin{1};
iv = find(cellfun(@ischar,varargin),1); if isempty(iv), iv = nargin+1; end

% contract the tensors pairwise from left to right
[M,i] = operand(varargin{1},varargin{2});
for k = 3:2:iv-1
  [B,j] = operand(varargin{k},varargin{k+1});
  [M,i] = contract(M,i,B,j);
end

assert(all(i>0),'Every summation index has to appear exactly twice.')

% output dimensions in the order of the indices
[i,order] = sort(i);
M = permute(M,[order, numel(i)+1:max(ndims(M),numel(i))]);

if isempty(i)
  T = M;
elseif strcmp(class(T),'tensor') || check_option(varargin(iv:end),'keepClass') %#ok<STISA>
  T.M = M;
  T.rank = numel(i);
else
  fr = T.framePrivate;
  T = tensor(M,T.CS,'noCheck','rank',numel(i));
  T.framePrivate = fr;
end

end

%%
function [M,i] = operand(A,i)
% the coefficients as plain array, tensor dimensions first

if isa(A,'tensor')
  M = A.M;
elseif isa(A,'quaternion')
  M = matrix(A);
elseif isa(A,'vector3d')
  M = shiftdim(fullDouble(A),ndims(A));
else
  M = A;
end
i = i(:).';

% sum the diagonal of any two dimensions carrying the same index
while numel(unique(i)) < numel(i)
  p = find(i == i(find(sum(i == i.',1) > 1,1)));
  n = size(M,p(1));
  s = size(M,1:max(ndims(M),numel(i)));
  r = setdiff(1:numel(s),p);
  M = reshape(permute(M,[p r]),n*n,[]);
  M = reshape(sum(M(1:n+1:end,:),1),[s(r) 1 1]);
  i(p) = [];
end

end

%%
function [M,i] = contract(M,i,B,j)
% one pagewise matrix product: shared negative indices form the inner
% dimension, shared positive indices and the array dimensions the pages

sM = size(M,1:max(ndims(M),numel(i)));
sB = size(B,1:max(ndims(B),numel(j)));

c = intersect(i,j);
[~,ci] = ismember(c,i); [~,cj] = ismember(c,j);
nc = nnz(c<0);
fi = setdiff(1:numel(i),ci); fj = setdiff(1:numel(j),cj);

% array dimensions padded to a common length
aM = sM(numel(i)+1:end); aB = sB(numel(j)+1:end);
na = max(numel(aM),numel(aB)); aM(end+1:na) = 1; aB(end+1:na) = 1;

M = permute(M,[fi ci numel(i)+(1:na)]);
M = reshape(M,[prod(sM(fi)) prod(sM(ci(1:nc))) sM(ci(nc+1:end)) aM]);
B = permute(B,[cj fj numel(j)+(1:na)]);
B = reshape(B,[prod(sB(cj(1:nc))) prod(sB(fj)) sB(cj(nc+1:end)) aB]);

M = pagemtimes(M,B);
M = reshape(M,[sM(fi) sB(fj) sM(ci(nc+1:end)) max(aM,aB) 1 1]);
i = [i(fi) j(fj) c(nc+1:end)];

end
