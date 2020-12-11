function T = EinsteinSum(varargin)
% tensor multiplication according to Einstein summation convention
%
% Description
% This function computes a tensor product according to Einstein summation
% convention
%
% Syntax
%   % sumation against dimension 1 and 2
%   C = EinsteinSum(E,[1 -1 2 -2],v,-1,v,-2) 
%
%   eps = EinsteinSum(C,[-1 1 -2 2],sigma,[-1 -2])
%
% Input
%  T1,T2 - @tensor
%  dimT1 - vector of indices giving the summation order in tensor 1
%  dimT2 - vector of indices giving the summation order in tensor 2
%
% Output
%  T - @tensor
%
% See also
%

% TODO: check for correct symmetries !!!

global useBSXFUN;

M1 = 1; dimT1 = [];
T = varargin{1};

% for each tensor in varargin
iv = 1;
while iv < length(varargin) && ~ischar(varargin{iv})

  % take new vector from varargin
  M2 = varargin{iv};
  dimT2 = varargin{iv+1};
  iv = iv+2;
      
  % convert to double
  if isa(M2,'tensor')
    M2 = M2.M;
  elseif isa(M2,'quaternion')
    M2 = matrix(M2);
  elseif isa(M2,'vector3d')
    M2 = double(M2);
    M2 = permute(M2,[3 1 2]);
  end
 
  %
  if length(dimT2) > 1 && sum(dimT2<0)>1 && max(accumarray(-dimT2(dimT2<0).',1)>1)
    [M2,dimT2] = innerSum(M2,dimT2);
  end
  
  % reorder T1 such that [-rDel ... -3 -2 -1  1 2 3 .. rOut x x x]
  rOut = max([0,dimT1,dimT2]);
  rDel = -min([0,dimT1,dimT2]);
  rExt = max([0,ndims(M1) - length(dimT1), ndims(M2) - length(dimT2)]);
  
  % new order of dimensions for tensor 1
  dimT1(dimT1>0) = dimT1(dimT1>0) - 1;  % we should start with zero to avoid the cap
  exp1 = 1:rOut + rDel; exp1(dimT1 + rDel + 1) = []; % dimensions in reserve 
  order1 = [dimT1 + rDel + 1,...  the tensor components
    rOut + rDel + (1:rExt),...    none tensor components 
    exp1];
  
  % new order of dimensions for tensor 2
  dimT2(dimT2>0) = dimT2(dimT2>0) - 1; % we should start with zero to avoid the cap
  exp2 = 1:rOut + rDel; exp2(dimT2 + rDel + 1) = []; % dimensions in reserve 
  order2 = [dimT2 + rDel + 1,...  the tensor components
    rOut + rDel + (1:rExt),...    none tensor components 
    exp2];
   
  M1 = ipermute(M1,order1);
  M2 = ipermute(M2,order2);
    
  if useBSXFUN
    M1 = bsxfun(@times, M1, M2);
  else
    M1 = M1 .* M2;
  end
  
  % setup dimT1
  dimT1 = [-rDel:-1,1:rOut];
  
end

% sum over the dimensions to be removed
if useBSXFUN
  if rDel>0, M1 = sum(M1,1:rDel); end
else
  for d = 1:rDel, M1 = sum(M1,d); end
end

% and remove these leading dimensions
s = size(M1);
M1 = reshape(M1,[s(rDel+1:end) 1 1]);

% rank 0 tensor should become double
if rOut == 0
  T = M1; 
elseif strcmp(class(T),'tensor') || check_option(varargin(iv:end),'keepClass')
  T.M = M1;
  T.rank = rOut;
else
  T = tensor(M1,T.CS,'noCheck','rank',rOut,varargin{iv:end});
end

end

%%
function [M,ind] = innerSum(M,ind)

% find indices to be summed
[a,b] = findDouble(ind);

if isempty(a), return;end

ind([a,b]) = [];

% remember size of matrix
sM = size(M);
sM([a,b]) = [];

% make a,b the first two dimensions
order = 1:max([ndims(M) a b]);
order([a b]) = [];
order = [a b order];
M = permute(M,order);

% reduces multiple remove dimensions to one
M = reshape(M,3^numel(a),3^numel(b),[]);

% sum along the diagonal of the first two dimensions
N = zeros(1,1,size(M,3));
for l = 1:3^numel(a)
  N = N + M(l,l,:);
end

% reshape back
M = reshape(N,[sM 1 1]);

end

%%
function [a,b] = findDouble(x)

%if length(x) <= 1 || all(x>=0) || sum(x<0)<2 || max(accumarray(-x(x<0).',1))<2
%  a = [];
%  b = [];
%  return;
%end

d = bsxfun(@minus,x,x') == 0 & bsxfun(@times,x<0,x'<0);
d = d & ~tril(ones(size(d)));
[a,b] = find(d);
a = a'; b = b';
 
end
