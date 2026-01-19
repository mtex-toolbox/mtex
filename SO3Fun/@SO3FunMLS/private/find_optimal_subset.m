function opt_sub_ind = find_optimal_subset(SO3F, ind, ori, varargin)


% compute for given index sets ind(.,:) describing points of SO3F.nodes 
%   and polynomial degree (given by SO3F) the OPTimal SUBset INDice


% inputs:
%   SO3F    - @SO3FunMLS, containing data like nodes, degree, dimension of poly space, ...
%   ind     - N x numel(SO3F.nodes) logical array describing sets of nodes
%   ori     - the centers where the MLS approximation is to be evaluated

% outputs: 
%   opt_sub_ind  - a N x numel(SO3F.nodes) logical array with 
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
N = numel(ori);
grid_size = numel(SO3F.nodes);
dim = SO3F.dim;

opt_sub_ind = zeros(N, dim);
num_threads = get_option(varargin, 'threads', 1, 'double');


% if ind is N x nn, we convert it into sparse logical N x grid_size array first
if (isa(ind, 'double') == true)
  n = size(ind, 2);
  row_idx = repmat((1:N)', 1, n);
  ind = sparse(row_idx, ind, true, N, grid_size, N*n);
end 


% set linprog options to suppress output
ver = version;
ver = str2double(ver(1:2));
% we want to use primal-dual simplex, since it is faster
% but in matlab >= R2025a it throws the error "Unrecognized field name "optimstatus" 
% due to some internal bug in linprog
if (ver < 25)
  options = optimoptions('linprog','Display','none'); 
else
  % very robust
  options = optimoptions('linprog', 'Display','none', 'Algorithm','interior-point-legacy');
  warning(['linprog was set to use interior-point-legacy instead of primal-dual-simplex, ' ...
    'since the latter throws the error'])
end

c = SO3F.eval_basis_functions(orientation.id);

% get numbers of neighbors
ns = sum(ind, 2);

inv_ori = inv(ori);

if (num_threads == 1)
  for i = 1 : N
    n = ns(i); 
    b = ones(2*n, 1);

    % now the vandermonde matrix
    rot_neighbors = inv_ori(i) * SO3F.nodes.subSet(ind(i,:));
    halfM = SO3F.eval_basis_functions(rot_neighbors);

    % find the worst poly p* via linprog
    M = [halfM; -halfM];
    [~, ~, ~, ~, lambda] = linprog(c, M, b, [], [], [], [], options);
    
    % get the optimal subset markers
    % due to numerical instability, many lambdas are almost 0, but not precisely 0
    % thus we choose the optimal subset to consist of the indice where the
    %   lambdas are largest
    % of course we have to keep in mind that 2 inequalities pair together to an
    %   equality
    grid_idx = find(ind(i,:));
    lambdas = reshape(lambda.ineqlin, n, 2);
    lambdas = max(abs(lambdas), [], 2);
    [~, id] = sort(lambdas, 'descend');
    opt_sub_ind(i,:) = grid_idx(id(1:SO3F.dim));
  end

else
  parfor(i = 1 : N, num_threads)
    n = ns(i);
    b = ones(2*n, 1);

    % now the vandermonde matrix
    rot_neighbors = inv_ori(i) * SO3F.nodes.subSet(ind(i,:));
    halfM = SO3F.eval_basis_functions(rot_neighbors);

    % find the worst poly p* via linprog
    M = [halfM; -halfM];
    [~, ~, ~, ~, lambda] = linprog(c, M, b, [], [], [], [], options);

    % get the optimal subset markers
    % due to numerical instability, many lambdas are almost 0, but not precisely 0
    % thus we choose the optimal subset to consist of the indice where the
    %   lambdas are largest
    % of course we have to keep in mind that 2 inequalities pair together to an
    %   equality
    grid_idx = find(ind(i,:));
    lambdas = reshape(lambda.ineqlin, n, 2);
    lambdas = max(abs(lambdas), [], 2);
    [~, id] = sort(lambdas, 'descend');
    opt_sub_ind(i,:) = grid_idx(id(1:SO3F.dim));
  end
end


if (is_logical == true)
  row_idx = repmat((1:N)', 1, dim);
  opt_sub_ind = sparse(row_idx, opt_sub_ind, true, N, grid_size, N*dim);
end


end