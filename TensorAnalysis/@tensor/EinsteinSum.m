function T = EinsteinSum(T1,dimT1,varargin)
% tensor multiplication according to Einstein summation
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

% sum over equal negative values in dimT1
[T1.M,dimT1] = innerSum(T1.M,dimT1);
T1.rank = numel(dimT1);

% for each tensor in varargin
while ~isempty(varargin) && ~ischar(varargin{1})

  % take new vector from varargin
  M2 = varargin{1};
  dimT2 = varargin{2};
  varargin = varargin(3:end);
    
  % convert to matrix
  if isa(M2,'tensor')
    M2 = M2.M;
  elseif isa(M2,'quaternion')
    M2 = matrix(M2);
  elseif isa(M2,'vector3d')
    M2 = double(M2);
    M2 = permute(M2,[3 1 2]);
  end
  
  % sum over equals negative values in dimT2
  [M2,dimT2] = innerSum(M2,dimT2);
    
  % get ranks and sizes
  [r1,sT1,l1] = getSize(T1.M,dimT1);
  [r2,sT2,l2] = getSize(M2,dimT2);
  T1.M = reshape(T1.M,[sT1,l1,1,1]);
  M2 = reshape(M2,[sT2,l2,1,1]);
  ll = max(l1,l2);    
  
  % -------- check for equals negative values in dimT1 and dimT2 ----
  
  [a,b] = findDouble([dimT1,dimT2]);
  b = b - length(dimT1);
    
  if ~isempty(a)
    
    % reorder tensor1 such that dimensions to remove come at first position
    order = 1:numel(sT1)+1;
    order(a) = [];
    order = [a,order];    %#ok<AGROW>
    dimT1(a) = [];
    sTa = sT1(a);
    sT1(a) = [];        
    T1.M = permute(T1.M,order);
        
    % reorder tensor2 such that dimensions to remove come at first position
    order = 1:numel(sT2)+1;
    order(b) = [];
    order = [b,order]; %#ok<AGROW>
    
    dimT2(b) = [];  
    sTb = sT2(b);
    sT2(b) = [];
    M2 = permute(M2,order);

  else
    sTa = []; sTb = [];
  end
    
  % ------------------ join matrix 1 and matrix 2 -------------
  if ~isempty(M2)
    
    if (l1 == 1) || (l2 == 1)

      M1 = reshape(T1.M,prod(sTa),[]).';
            
      M2 = reshape(M2,prod(sTb),[]);
        
      % mulitply
      T1.M = M1 * M2; % prod(st1) x l1 x prod(st2) x l2
      
      if l1 ~= 1 % put the l1 dimension to the end
        
        T1.M = reshape(T1.M,prod(sT1),l1,prod(sT2));
        T1.M = permute(T1.M,[1 3 2]);
        
      end
      
    else
        
      % reshape T1.M and T2.M such that they fit
      M1 = reshape(T1.M,[...
        prod(sTa),...
        sT1,...
        ones(1,numel(sT2)),...
        l1]);
        
      M2 = reshape(M2,[...
        prod(sTb),...
        ones(1,numel(sT1)),...
        sT2,...
        l2]);
    
      % mulitply
      T1.M = sum(bsxfun(@times,M1,M2),1);
      
    end
    
    % remove singleton dimensions      
    T1.M = reshape(T1.M,[sT1,sT2,ll,1,1]);
    
    % combine rank
    dimT1 = [dimT1 dimT2]; %#ok<AGROW>
    
    % set rank
    T1.rank = numel(dimT1);
    
  end
    
end

% ----------------- reorder dimension ------------------------
order = 1:max(T1.rank,ndims(T1.M));
order(1:length(dimT1)) = dimT1;

try
  T1.M = ipermute(T1.M,order);
catch %#ok<CTCH>
  error(['Bad indice! Positive indice has to be a permutation of the numbers: ' num2str(1:ndims(T1.M))])
end

% remove name and unit
T = T1.rmOption('name','unit');
  
if check_option(varargin,'doubleconvention')
  T.doubleConvention = true;
end


varargin = delete_option(varargin,{'doubleconvention','singleconvention','InfoLevel'});

% extract options
T = T.setOption(varargin{:});

end

% ------------------- private functions -------------------------

function [r,s,l] = getSize(M,ind)

r = numel(ind);

s = ones(1,r);
s(1:ndims(M)) = size(M);
s = s(1:r);

l = numel(M) / prod(s);

end

function [a,b] = findDouble(x)

d = bsxfun(@minus,x,x') == 0 & bsxfun(@times,x<0,x'<0);
d = d & ~tril(ones(size(d)));
[a,b] = find(d);
a = a'; b = b';
 
end

% 
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
