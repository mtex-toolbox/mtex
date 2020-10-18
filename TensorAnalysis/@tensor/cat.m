function T = cat(dim,varargin)
% overloads [T1,T2,T3..]

% copy first
T = varargin{1};

% copy data
M = cell(size(varargin));

for i = 1:numel(varargin)

  M{i}= varargin{i}.M;
  
  % check for equal rank
  assert(T.rank == varargin{i}.rank,'Tensors should have equal rank!');

  % check for equal symetries
  assert(T.CS == varargin{1}.CS,'Tensors should have equal symmetry');
    
end

T.M = cat(T.rank+dim,M{:});
