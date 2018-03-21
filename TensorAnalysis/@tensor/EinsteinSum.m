function T = EinsteinSum(T1,dimT1,varargin)
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

M1 = T1.M;

% for each tensor in varargin
while ~isempty(varargin) && ~ischar(varargin{1})

  % take new vector from varargin
  M2 = varargin{1};
  dimT2 = varargin{2};
  varargin = varargin(3:end);
    
  % convert to double
  if isa(M2,'tensor')
    M2 = M2.M;
  elseif isa(M2,'quaternion')
    M2 = matrix(M2);
  elseif isa(M2,'vector3d')
    M2 = double(M2);
    M2 = permute(M2,[3 1 2]);
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
  
  % TODO: later use M = M1 .* M2;
  M1 = bsxfun(@times, M1, M2); 
  
  % setup dimT1
  dimT1 = [-rDel:-1,1:rOut];
  
end

% sum over the dimensions to be removed
for i = 1:rDel, M1 = sum(M1,i); end

% and remove these leading dimensions
s = size(M1);
M1 = reshape(M1,s(rDel+1:end));

% rank 0 tensor should become double
if rOut == 0
  T = M1; 
else
  T = tensor(M1,'rank',rOut,varargin{:});
end

end
