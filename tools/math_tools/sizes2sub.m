function [row_idx, col_idx] = sizes2sub(sizes)

% Given the integer sizes of certain arrays, return the row- and column-indices
%   needed for dealing the subarrays into the columns of a matrix.

% Syntax:
%   [row_idx, col_idx] = sizes2sub(sizes);
%
% Input:
%   sizes - an array of the sizes of certain 1D-arrays
%   
% Output: 
%   row_idx: 1..sizes(1) , 1..sizes(2) , ... , concatenated
%   col_idx: 1 repeated A(1) times , 2 repeated A(2) times , ...


sizes = sizes(:);
n = numel(sizes);

if n == 0
  row_idx = zeros(0,1);
  col_idx = zeros(0,1);
  return;
end

totalsize = sum(sizes);

% Starting offsets per block
start = cumsum([0; sizes(1:end-1)]);

% row indices within each block: global positions minus block offset
row_idx = (1:totalsize)' - repelem(start, sizes);

if (nargout > 1)
  % Column indices: [1...1 , 2...2, ... , n...n]
  col_idx = repelem((1:n)', sizes);
end

end
