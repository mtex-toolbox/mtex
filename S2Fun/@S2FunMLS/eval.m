function vals = eval(sF, v)
% evaluate sF on v via moving least squares (MLS) approximation
%
% Syntax
% vals = sF.eval(v)
% vals = eval(sF,v)
%
% Input
% sF    - the function we want to approximate
% v     - the points where we want to evaluate the MLS approximation
%
% Output
% vals  - the values of sF on v

if sF.centered
  vals = eval_centered(sF, v);
  return;
end

% get the number of points in v
s = size(v, 1);

% get the neighbors and the distance to them
if isa(sF.nodes, 'fibonacciS2Grid')
  [g_id, t_id, nn, dist] = sF.nodes.find(v, sF.delta);
else
  ind = sF.nodes.find(v, sF.delta);
  [g_id, t_id] = find(ind);
  dist = acos(dot(sF.nodes.subSet(g_id), v.subSet(t_id)));
  nn = sum(ind, 1);
end

% determine the dimension of the ansatz space
if sF.all_degrees
  dim = (sF.degree + 1)^2;
else
  dim = (sF.degree + 1) * (sF.degree + 2) / 2;
end

% create index vectors in order to use pagefuns
nn_total = sum(nn);
nn_max = max(nn);
start_id = cumsum(nn(1:end-1)) + 1;
B = ones(nn_total, 1);
B(start_id) = 1 - nn(1:end-1);
row_id = cumsum(B);
col_id = (t_id-1) * nn_max + row_id;

% evaluate the basis functions on the nodes
% choose faster way between computing all values and reusing them or
% computing values on fibgrid(g_id)
B = zeros(dim, nn_max * s);
if nn_total > numel(sF.nodes.x)
  base_on_grid = eval_base_functions(sF);
  B(:, col_id) = base_on_grid(g_id, :)';
else
  B(:, col_id) = eval_base_functions(sF, sF.nodes.subSet(g_id))';
end
B_book = reshape(B, dim, nn_max, s);

% assemble the Gram matrix
w = zeros(s * nn_max, 1);
w(col_id) = sF.w(dist / sF.delta);
BXw = B .* w';
BXw_book = reshape(BXw, dim, nn_max, s);
G_book = pagemtimes(BXw_book, pagetranspose(B_book));

% assemble the right hand side of the Gram system
fXw = zeros(nn_max * s, 1);
fXw(col_id) = sF.values(g_id) .* w(col_id);
fdotu = B .* fXw';
fdotu_book = sum(reshape(fdotu, dim, nn_max, s), 2);

% solve the systems and evaluate the MLS approximation
c_book = pagemldivide(G_book, fdotu_book);
c = reshape(c_book, dim, s);
base_on_v = eval_base_functions(sF, v);
vals = sum(c' .* base_on_v, 2);

if isreal(sF.values)
  vals = real(vals);
end

end