function [ind,d] = find(v,w,epsilon_or_k,varargin)
% return indices and distances of all nodes within v, which are in an epsilon 
% neighborhood of w.
% Or, alternatively return the k nearest points.
%
% Syntax  
%   [ind,d] = find(v,w)         % find closest point out of v to w
%   ind = find(v,w,epsilon) % find all points out of v in an epsilon neighborhood of w
%   ind = find(v,w,k)       % find k nearest points out of v to w
%
% Input
%  v, w         - @quaternion
%  epsilon_or_k - epsilon or k (see below), depending on what the user wants
%  epsilon      - double
%  k            - int32
%
% Output
%  ind          - int32 array for k nearest neighbors,
%               - sparse logical incidence matrix for region search
%  d            - double array for k nearest neighbors, 
%               - sparse double array for region search (0 whenever ind is 0)

% TODO: knnsearch() and rangesearch() needs Statistical Toolbox


if isa(w,'fibre')
  d = angle(w,v.subSet(:));
  if (floor(epsilon_or_k) == epsilon_or_k)
    [d,ind] = mink(d,epsilon_or_k); 
  else
    ind = sparse(d < epsilon_or_k);
    d = sparse(d(ind));
  end
  return
end

% % compute with distances
% d = angle(v.subSet(:).',w.subSet(:));
% if nargin==2, epsilon_or_k=1; end
% if (floor(epsilon_or_k) == epsilon_or_k)
%   [d,ind] = mink(d,epsilon_or_k,2);
% else
%   ind = sparse(d < epsilon_or_k);
%   d = sparse(d(ind));
% end

if nargin==2, epsilon_or_k=1; end

% add -v to v
% TODO: Do better with respect to epsilon
orig_size = numel(v);
v = [-v;v];

% k given ==> find k nearest neighbors
if (floor(epsilon_or_k) == epsilon_or_k)
  ind = knnsearch(v.abcd, w.abcd, 'K', epsilon_or_k);
  if (nargout == 2)
    d = angle(v.subSet(ind), w);
  end
  % 'project' the indices back from [v,-v] to the original grid v
  ind = mod(ind-1, orig_size) + 1;
  return
end

% epsilon given ==> perform range-search with radius epsilon
% scale spherical region to euclidean region before starting rangesearch
ind = rangesearch(v.abcd, w.abcd, sqrt(2) * sqrt(1 - cos(epsilon_or_k/2)));
% first convert ind into sparse logical matrix of size numel(w) x numel(v)
lens = cellfun(@numel, ind);
row_idx = repelem((1:numel(w)), lens);
col_idx = cell2mat(ind');
% 'project' the indices back from [v,-v] to the original grid v
col_idx = mod(col_idx-1, orig_size) + 1; 
ind = sparse(row_idx, col_idx, true(sum(lens),1), numel(w), orig_size); 

if (nargout == 2)
  d = angle(v.subSet(col_idx), reshape(w.subSet(row_idx), numel(row_idx), 1));
  % also convert d to sparse after computing it
  d = sparse(row_idx, col_idx, d, numel(w), orig_size);
end

end