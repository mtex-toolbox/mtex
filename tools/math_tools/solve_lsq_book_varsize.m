function [c_book, conds, info] = ...
    solve_lsq_book_varsize(weights, basis_values, f_values, sizes, varargin)

% same local solver as solve_lsq_book_constsize, but neighborhood sizes vary
% entries belonging to one system are stored consecutively

sizes = sizes(:);
dim = size(basis_values, 2);
numf = size(f_values, 2);
N = numel(sizes);

min_size = min(sizes);
max_size = max(sizes);

% Similar neighborhood sizes can be padded and solved in one pagewise call.
if (max_size / min_size <= 2)
  system_id = repelem((1:N)', sizes);
  idx = (1 : sum(sizes))';
  starts = cumsum([1; sizes(1:end-1)]);
  col_id = idx - starts(system_id) + 1 + (system_id - 1) * max_size;

  W_book = zeros(max_size * N, 1, 'like', weights);
  W_book(col_id) = weights;
  W_book = reshape(W_book, max_size, 1, N);

  G_book = zeros(max_size * N, dim, 'like', basis_values);
  G_book(col_id,:) = basis_values;
  G_book = permute(reshape(G_book.', dim, max_size, N), [2, 1, 3]);

  f_book = zeros(max_size * N, numf, 'like', f_values);
  f_book(col_id,:) = f_values;
  f_book = permute(reshape(f_book.', numf, max_size, N), [2, 1, 3]);

  if nargout <= 1
    c_book = solve_lsq_book_constsize(W_book, G_book, f_book, varargin{:});
  elseif nargout == 2
    [c_book, conds] = ...
      solve_lsq_book_constsize(W_book, G_book, f_book, varargin{:});
  else
    [c_book, conds, info] = ...
      solve_lsq_book_constsize(W_book, G_book, f_book, varargin{:});
  end
  return;
end

% Otherwise group systems by comparable size and recurse.
start_id = cumsum([1; sizes(1:end-1)]);
row_id = (1 : sum(sizes))';
system_id = repelem((1:N)', sizes);
col_id = row_id - start_id(system_id) + 1;
auxmat = sparse(col_id, system_id, row_id, max_size, N, sum(sizes));

c_book = zeros(dim, numf, N, 'like', f_values);
if nargout > 1
  conds = zeros(N, 1);
end
if nargout > 2
  info = initRegInfo(N);
end

current_max_size = 2 * min_size;
while min_size <= max_size
  I = (sizes >= min_size) & (sizes <= current_max_size);
  min_size = current_max_size + 1;
  current_max_size = current_max_size * 2;

  % Some dyadic size intervals can be empty for strongly varying neighborhoods.
  if ~any(I), continue; end

  J = nonzeros(auxmat(:,I));
  varargin_batch = slicePageOptions(varargin, I, N);

  if nargout <= 1
    c_book(:,:,I) = solve_lsq_book_varsize(weights(J,:), ...
      basis_values(J,:), f_values(J,:), sizes(I), varargin_batch{:});
  elseif nargout == 2
    [c_book(:,:,I), conds(I)] = solve_lsq_book_varsize(weights(J,:), ...
      basis_values(J,:), f_values(J,:), sizes(I), varargin_batch{:});
  else
    [c_book(:,:,I), conds(I), info_batch] = ...
      solve_lsq_book_varsize(weights(J,:), basis_values(J,:), ...
      f_values(J,:), sizes(I), varargin_batch{:});
    info = insertRegInfo(info, I, info_batch);
  end
end

end


% initialize struct for additional regularization information
function info = initRegInfo(N)
  info = struct;
  info.conds_reg = NaN(N, 1);
  info.conds_unreg = NaN(N, 1);
  info.maxeig = NaN(N, 1);
  info.mineig = NaN(N, 1);
  info.maxeig_reg = NaN(N, 1);
  info.mineig_reg = NaN(N, 1);
  info.centerAmplification = NaN(N, 1);
  info.centerAmplificationRegBound = NaN(N, 1);
  info.numericalRidge = NaN(N, 1);
  info.shapeRegularization = NaN(N, 1);
  info.regularizationActive = false(N, 1);
end

% insert regularization information of one batch into the complete struct
function info = insertRegInfo(info, I, info_batch)
  names = fieldnames(info_batch);
  for k = 1 : numel(names)
    name = names{k};
    if isfield(info, name)
      info.(name)(I,:) = info_batch.(name);
    end
  end
end

% Restrict pagewise options, in particular the evaluation vector, to a batch.
function varargin = slicePageOptions(varargin, I, N)
  for k = 1 : numel(varargin)-1
    if ischar(varargin{k}) || isstring(varargin{k})
      name = lower(char(varargin{k}));
      if any(strcmp(name, ...
          {'eval_vector', 'evaluation_vector', 'center_vector'}))
        value = varargin{k+1};
        if ndims(value) >= 3 && size(value,3) == N
          varargin{k+1} = value(:,:,I);
        elseif ismatrix(value) && size(value,2) == N
          varargin{k+1} = value(:,I);
        end
      end
    end
  end
end
