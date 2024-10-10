function [vals, conds] = eval_centered(sF, v)

% evaluate sF on v via moving least squares (MLS) approximation
% provide the possibility of also returning the condition numbers of the gram matrices
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

% compute the rotations that shift each element of v into the north pole
rot = rotation.map(v, vector3d.Z);
rot = rot(t_id);
rotneighbors = rot .* sF.nodes(g_id);

% determine which basis to use and evaluate them on the grid and on v
if sF.all_degrees
  if sF.monomials
    base_on_grid = [eval_monomials(rotneighbors, sF.degree) ...
                    eval_monomials(rotneighbors, sF.degree-1)];
    base_in_pole = [eval_monomials(vector3d.Z, sF.degree) ...
                    eval_monomials(vector3d.Z, sF.degree-1)];
    base_on_v = repmat(base_in_pole, s, 1);
  else
    base_on_grid = [eval_monomials(rotneighbors, sF.degree) ...
                    eval_monomials(rotneighbors, sF.degree-1)];
    base_in_pole = [eval_monomials(vector3d.Z, sF.degree) ...
                    eval_monomials(vector3d.Z, sF.degree-1)];
    base_on_v = repmat(base_in_pole, s, 1);
  end
else
  if sF.monomials
    base_on_grid = eval_monomials(rotneighbors, sF.degree, sF.tangent);
    base_in_pole = eval_monomials(vector3d.Z, sF.degree, sF.tangent);
    base_on_v = repmat(base_in_pole, s, 1);
  else
    base_on_grid = eval_spherical_harmonics(rotneighbors, sF.degree);
    base_in_pole = eval_spherical_harmonics(vector3d.Z, sF.degree);
    base_on_v = repmat(base_in_pole, s, 1);
  end
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
B = zeros(dim, nn_max * s);
B(:, col_id) = base_on_grid';
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

% rescale the system before solving it
% the row i and column i are rescaled by 1/sqrt(Gii), such that the absolute
% values on the diagonal become 1
pageidx = (1:dim+1:dim^2)';
bookidx = (1:dim^2:s*dim^2)-1;
idx = pageidx + bookidx;
S = zeros(dim, dim, s);
S(idx(:)) = 1 ./ sqrt(abs(G_book(idx(:))));
G_book_scaled = pagemtimes(pagemtimes(S, G_book), S);
fdotu_book = pagemtimes(S, fdotu_book);

% solve the systems and evaluate the MLS approximation
c_book = pagemldivide(G_book_scaled, fdotu_book);
c_book = pagemtimes(S, c_book);
c = reshape(c_book, dim, s);
vals = sum(c' .* base_on_v, 2);

if isreal(sF.values)
  vals = real(vals);
end

if nargout == 2
  conds = zeros(s, 1);
  for i = 1 : s
    conds(i) = cond(G_book_scaled(:,:,i));
  end
end

end
