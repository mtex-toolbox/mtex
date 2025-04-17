function [ind,d] = find(v,w,epsilon_or_k,varargin)
% return index of all points in an epsilon neighborhood of a vector
%
% Syntax
%   ind = find(v,w)         % find closest point out of v to w
%   ind = find(v,w,epsilon) % find all points out of v in an epsilon neighborhood of w
%   ind = find(v,w,k)       % find k nearest points out of v to w
%
% Input
%  v, w         - @vector3d
%  epsilon_or_k - epsilon or k (see below), depending on what the user wants
%  epsilon      - double
%  k            - int32
%
% Options
%  antipodal    - include <VectorsAxes.html antipodal symmetry>
%
% Output
%  ind          - int32 array for k nearest neighbors,
%               - sparse logical incidence matrix for region search
%  d            - double array for k nearest neighbors, 
%               - sparse double array for region search (0 whenever ind is 0)

% check for antipodal option
if (numel(varargin) > 0)
  if (strcmp(varargin{1}, 'antipodal'))
    % storing the option in v lets @vector3d.angle take care of computing the
    % distance the right way 
    v.antipodal = true;
  end
end

% if v or w is antipodal, we also search for neighbors on the opposite side of
% the sphere
% later, we will have to 'project' the indice back down to the original grid v
% this is done via the modulo operator, see below
orig_size = numel(v);
if (v.antipodal || w.antipodal)
  v = [v;-v];
end

if (nargin >= 3)
  % k given ==> find k nearest neighbors
  if (floor(epsilon_or_k) == epsilon_or_k)
    k = epsilon_or_k;
    ind = knnsearch(v.xyz, w.xyz, 'K', k);
    if (nargout == 2)
      d = angle(v.subSet(ind), w);
    end
    % if v or w was antipodal, we 'doubled' the grid to [v;-v] and must now
    % 'project' the indice down to the original grid v
    ind = mod(ind-1, orig_size) + 1;

  % epsilon given ==> perform range-search with radius epsilon
  else
    epsilon = epsilon_or_k;
    % scale spherical region to euclidean region before starting rangesearch
    ind = rangesearch(v.xyz, w.xyz, sqrt(2) * sqrt(1 - cos(epsilon)));
    % first convert ind into sparse logical matrix of size numel(w) x numel(v)
    lens = cellfun(@numel, ind);
    row_idx = repelem((1:numel(w)), lens);
    col_idx = cell2mat(ind');
    % if v or w was antipodal, we 'doubled' the grid to [v;-v] and must now
    % 'project' the indice down to the original grid v
    col_idx = mod(col_idx-1, orig_size) + 1; 
    ind = sparse(row_idx, col_idx, true(sum(lens),1), numel(w), numel(v)); 
    if (nargout == 2)
      d = angle(v.subSet(col_idx), w.subSet(row_idx));
      % also convert d to sparse after computing it
      d = sparse(row_idx, col_idx, d, numel(w), numel(v));
    end
  end

% only 2 inputs specified ==> perform nearest-neighbor search
else 
  ind = knnsearch(v.xyz, w.xyz);
  if (nargout == 2)
    d = angle(v.subSet(ind), w);
  end
  % if v or w was antipodal, we 'doubled' the grid to [v;-v] and must now
  % 'project' the indice down to the original grid v
  ind = mod(ind-1, orig_size) + 1;
end