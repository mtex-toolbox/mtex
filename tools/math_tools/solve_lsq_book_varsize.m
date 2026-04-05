function [c_book, conds] = solve_lsq_book_varsize(weights, basis_values, f_values, sizes,  varargin)

% same as solve_lsq_book_constsize, but G does now have varibale size
% overall we get N = numel(sizes) many least squares problem
% portions of sizes(i) of each input belong to the same problem
% this function returns the solution vectors and the condition numbers
% one can also set flags and parameters for regularization and similiar things

% the computation is performed in batches, grouped by similar number of columns

% input:
%   sizes        - array containing number of columns per system 
%                    size: (N x 1)
%   weights      - array containing all weights for all systems
%                  sizes(i) consecutive weights for system i 
%                    size: (sum(sizes) x  N)
%   basis_values - array of values of the basis on each node of the same system
%                    size: (sum(sizes) x dim)
%   f_values     - array of values of f in the center of each lsq problem 
%                    size: (sum(sizes) x  numf)

% output:
%   c_books      - array of lsq coeffs for the basisfuns, of each lsq problem 
%                    size: (dim x numf x N)
%   conds        - array of condition number of each system
%                    size: (N x 1)


% get input array sizes
dim = size(basis_values, 2);
numf = size(f_values, 2);
N = numel(sizes);

% check if the sizes of the systems are similar
min_size = min(sizes);
max_size = max(sizes);
ratio = max_size / min_size;
if (ratio <= 2) 
  similarSize = true;
else
  similarSize = false;
end

% if the sizes are similar, we just create the 'books' and solve 
if (similarSize == true)
  % index vectors for dealing values to the book-pages
  system_id = repelem((1:N)', sizes, 1);
  idx = (1 : sum(sizes))';
  starts = cumsum([1; sizes(1 : end-1)]);
  offsets = (system_id - 1) * max_size;
  col_id = idx - starts(system_id) + 1 + offsets;
  clear idx offsets starts system_id;

  W_book = zeros(max_size * N, 1);
  W_book(col_id) = weights;
  W_book = reshape(W_book, max_size, 1, N);
  % for each page, normalize the mean weight to be 1
  W_book = W_book ./ mean(W_book, 1);

  G_book = zeros(max_size * N, dim);
  G_book(col_id,:) = basis_values;
  G_book = pagetranspose(reshape(G_book.', dim, max_size, N));

  f_book = zeros(max_size * N, numf);
  f_book(col_id,:) = f_values;
  f_book = pagetranspose(reshape(f_book.', numf, max_size, N));

  [c_book, conds] = solve_lsq_book_constsize(W_book, G_book, f_book, varargin{:});

  return;
end


% otherwise we have to group into batches of the same size before solving them

% create helper matrix for slicing the inputs
N = numel(sizes);
total_size = sum(sizes);
start_id = cumsum([1; sizes(1 : end-1)]);

row_id = (1 : total_size)';
system_id = repelem((1 : N)', sizes);
col_id = row_id - start_id(system_id) + 1;
auxmat = sparse(col_id, system_id, row_id, max_size, N, total_size);
clear col_id row_id start_id system_id;

% initialize return values
c_book = zeros(dim, numf, N);
conds = zeros(N, 1);

current_max_size = 2 * min_size;
% group in batches of similar size and call solver
while min_size <= max_size
  I = (sizes >= min_size) & (sizes <= current_max_size);
  min_size = current_max_size + 1;
  current_max_size = current_max_size * 2;

  % get the row_indice of the subproblems marked by I, and call solver
  J = nonzeros(auxmat(:,I));
  [c_book(:,:,I), conds(I)] = solve_lsq_book_varsize( ...
    weights(J,:), basis_values(J,:), f_values(J,:), sizes(I), varargin{:});
end

end