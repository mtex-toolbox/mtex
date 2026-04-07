function [c_book, conds] = solve_lsq_book_constsize(W_book, G_book, f_book, varargin)

% each page of the inputs defines a least squares problem
% this function returns the solution vectors and the condition numbers
% one can also set flags and parameters for regularization and similiar things

% input:
%   W_book - array of weights for each lsq problem
%              size: (nn x 1 x N)
%   G_book - array of values of the basis on each node of the same lsq system
%              size : (nn x dim x N)
%   f_book - array of values of f in the center of each lsq problem 
%              size: (nn x numf x N)

% output:
%   c_books      - array of lsq coeffs for the basisfuns, of each lsq problem 
%                    size: (dim x numf x N)
%   conds        - array of condition number of each system
%                    size: (N x 1)

% this function has 2 modes: with regularization or without regularization
regularize = check_option(varargin, {'regularize', 'regularization'});


% ==========================
% 1 - without regularization
% ==========================

% we compute B = sqrt(W) * G and fw =  sqrt(W) * f and solve B * c = fw
% also we apply some rescaling to B
% gram system would be B' * W * B * c = B' * W * f, but it has squared condition
if (regularize == false)
  % for each page, normalize the mean weight to be 1
  W_book = W_book ./ mean(W_book, 1);
  W_book = sqrt(W_book);
  
  B_book = W_book .* G_book;
  fw_book = W_book .* f_book;
  clear f_book G_book W_book;

  % compute scaling factors (norms of columns B_book)
  s_book = sqrt(sum(abs(B_book).^2, 1));

  % solve the rescaled systems and evaluate MLS
  c_book = pagemldivide(B_book ./ s_book, fw_book) ./ pagetranspose(s_book);
  clear fw_book s_book;

  if (nargout > 1)
    eigs = pagesvd(B_book);
    clear B_book;
    conds = max(eigs, [], 1) ./ min(eigs, [], 1);
    conds = conds(:);
  end

  return;
end


% =======================
% 2 - with regularization
% =======================

dim = size(G_book, 2);

% we solve the regularized systems (G' * W * G + lambda * I) *c = G' * W * f
% the regularization parameter depends on the condition of G' * W * G

% user-specified parameters for the regularization, see also get_t() at the end
% a good choice is dependent on the degree of S2F, the density of the data, ...
mincond = get_option(varargin, {'min_cond','mincond','min cond'}, 1e2);
maxcond  = get_option(varargin, {'maxcond', 'max cond', 'max_cond' }, 1e5);
alpha_min = 0;
alpha_max = 2;
exponent_p = get_option(varargin, 'p', 2);
exponent_q = get_option(varargin, 'q', 2);
basis_weights = get_option(varargin, ...
  {'basisweights','basis_weights','basis weights'}, ones(dim, 1), 'double');

% adapt weights 
% W_book = W_book ./ max(W_book, [], 1);
% nn = size(G_book, 1);
% k = round(nn * 1/2);
% k = min(max(k, 1), nn);
% wk = W_book(k,:,:);
% % exponent is solution of wk^exponent = 1/x, where x is the argument of the first log 
% exponent = -log(4) ./ log(wk); 
% W_book = W_book .^ reshape(exponent, 1, 1, []);
% W_book = W_book - min(W_book, [], 1);
% W_book = W_book ./ max(W_book, [], 1);

% create the gram matrices, scaled to have row- and column-norms equal to 1
B_book = sqrt(W_book) .* G_book;
clear G_book;
s_book = sqrt(sum(abs(B_book).^2, 1));
B_book = B_book ./ s_book;
Gram_book = pagemtimes(pagetranspose(B_book), B_book);
Gram_book = (Gram_book + pagetranspose(Gram_book)) / 2;

% assemble the right hand sides
rhs_book = pagemtimes(pagetranspose(B_book), sqrt(W_book) .* f_book);
clear f_book W_book;

% get the minimal and maximal eigen values
eigs = pagesvd(Gram_book);
maxeigs = reshape(max(eigs, [], 1), [], 1);
mineigs = max(reshape(min(eigs,[], 1), [], 1), eps(maxeigs) .* maxeigs);
clear eigs;

% get the regularization parameters (depending on rcond)
mincond = log10(mincond); 
maxcond = log10(maxcond);
Q = log10(maxeigs) - log10(mineigs);
Q = min(max(Q, mincond), maxcond);
t = get_t((Q - mincond) ./ (maxcond - mincond), exponent_p, exponent_q);

lambda_min = mineigs;
lambda_max = maxeigs;
lambda = lambda_min .* (lambda_max ./ lambda_min) .^ t;
alpha = alpha_min + (alpha_max - alpha_min) .* t;
clear maxeigs mineigs Q t;

% set up the regularized Gram matrix
dim = size(Gram_book, 1);

% punish higher-degree basis functions
R = basis_weights .^ reshape(alpha, 1, 1, []);
R = R ./ mean(R, 1);
clear alpha;
diag_offsets = permute(lambda, [2,3,1]) .* pagetranspose(R);
clear lambda R;
diag_in_page = (1 : dim+1 : dim^2)';
N = size(B_book, 3);
page_offset_idx = (0 : (N-1)) * dim^2;
diag_idx = reshape(diag_in_page + page_offset_idx, [], 1);
clear diag_in_page;

% squeeze is needed to avoid dimension mismatch when dim = 1
Gram_book(diag_idx) = squeeze(Gram_book(diag_idx)) + diag_offsets(:);
s2_book = sum(abs(Gram_book).^2, 1);
% s2_book = ones(size(s_book));
c_book = pagemldivide(Gram_book ./ s2_book, rhs_book) ./ pagetranspose(s_book .* s2_book);
clear diag_idx diag_offsets rhs_book s_book;

if (nargout > 1)
  eigs = pageeig(Gram_book);
  maxeigs = max(eigs, [], 1);
  mineigs = min(eigs, [], 1);
  mineigs = max(mineigs, 0);
  conds = maxeigs ./ mineigs;
  conds(mineigs == 0) = 1e100;
end

end

% smoothing function to adapt how much regularization is applied
% in case of MLS, the smoothness of get_t determines the smoothness of the MLS
function t = get_t(Q, p, q)
  Qp = Q .^ p;
  Qq = (1-Q) .^ q;
  t = Qp ./ (Qp + Qq);
end
