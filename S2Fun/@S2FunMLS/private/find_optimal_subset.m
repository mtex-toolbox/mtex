function opt_sub_ind = find_optimal_subset(S2F, ind, v, varargin)


% compute for given index sets ind(.,:) describing points of S2F.nodes 
%   and polynomial degree (given by S2F) the OPTimal SUBset INDice


% inputs:
%   S2F    - @S2FunMLS, containing data like nodes, degree, dimension of poly space, ...
%   ind    - N x numel(S2F.nodes) logical array describing sets of nodes
%   v      - the centers where the MLS approximation is to be evaluated

% outputs: 
%   opt_sub_ind  - a N x numel(S2F.nodes) logical array with 
%                    sum(optind, 2) = (dim,...,dim)  describing the optimal subsets 
%                    of cardinality = dim(ansatz space)


% NOTE: opt_sub_ind will first be a logical array of the same size as ind, which
%         is true if and only if the point belongs to the optimal subset
%       in the end it will be converted into the output format mentioned above


% we will find the optimal subsets by maximiziung p(0) over all polynomials with
%   -1 <= p(x_i) <= 1 for all x_i in X
% this is a linear program of the form max c' * p s.t. -1 <= M * p <= 1

% depending on if we perform a range-search or knn-search, ind will be a logical
%   indicator matrix or an array of indice
is_logical = isa(ind, 'logical');

% set parameters and initialize
N = size(ind, 1);
grid_size = numel(S2F.nodes);
dim = S2F.dim;

opt_sub_ind = zeros(N, dim);
num_threads = get_option(varargin, 'threads', 1, 'double');


% if ind is N x nn, we convert it into sparse logical N x grid_size array first
if (isa(ind, 'double') == true)
  n = size(ind, 2);
  row_idx = repmat((1:N)', 1, n);
  ind = sparse(row_idx, ind, true, N, grid_size, N*n);
end 


% set linprog options to suppress output
options = optimset('linprog');
options.Display = 'off';

c = S2F.eval_basis_functions(vector3d.Z);

% get numbers of neighbors
ns = sum(ind, 2);

rots = rotation.map(v, vector3d.Z);


if (num_threads == 1)
  for i = 1 : N
    n = ns(i); 
    b = ones(2*n, 1);

    % now the vandermonde matrix
    rotneighbors = rots(i) * S2F.nodes.subSet(ind(i,:));
    halfM = S2F.eval_basis_functions(rotneighbors);

    % find the worst poly p* via linprog
    M = [halfM; -halfM];
    [~, ~, ~, ~, lambda] = linprog(c, M, b, [], [], [], [], options);

    % get the optimal subset markers
    grid_idx = find(ind(i,:));
    opt_sub_ind(i,:) = grid_idx(any(reshape(lambda.ineqlin, n, 2), 2));
  end

else
  parfor(i = 1 : N, num_threads)
    n = ns(i);
    b = ones(2*n, 1);

    % now the vandermonde matrix
    rotneighbors = rots(i) * S2F.nodes.subSet(ind(i,:));
    halfM = S2F.eval_basis_functions(rotneighbors);

    % find the worst poly p* via linprog
    M = [halfM; -halfM];
    [~, ~, ~, ~, lambda] = linprog(c, M, b, [], [], [], [], options);

    % get the optimal subset indice
    grid_idx = find(ind(i,:));
    opt_sub_ind(i,:) = grid_idx(any(reshape(lambda.ineqlin, n, 2), 2));
  end
end


if (is_logical == true)
  row_idx = repmat((1:N)', 1, dim);
  opt_sub_ind = sparse(row_idx, opt_sub_ind, true, N, grid_size, N*dim);
end


end