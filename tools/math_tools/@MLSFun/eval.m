function [vals,conds,info,warnings] = eval(F,v,varargin)
% evaluate an MLS function by moving least squares
%
% Syntax
%   f = eval(F,v)
%   [f,conds,info] = eval(F,v)
%
% Input
%  F - @S2FunMLS, @SO3FunMLS
%  v - @vector3d, @orientation
%
% Output
%  f     - double [numel(v) × size(F)]
%  conds - condition numbers of the local systems
%  info  - struct of regularization diagnostics, one entry per point
%
% Description
% A fourth output returns the neighborhood warnings instead of printing
% them, the nested evaluations of the range search use it.

warnings = initWarnings;
emitWarnings = nargout < 4;
wantConds = nargout > 1;
wantInfo = nargout > 2;

if isempty(v)
  vals = [];
  conds = [];
  info = initRegInfo(0);
  return
end

[F,v] = F.prepareEval(v);

if F.detectOutliers && isempty(F.outlierIndicators)
  F.outlierIndicators = computeOutlierIndicators(F);
end

dimensions = size(v);
N = numel(v);

% degree zero is a weighted average and needs no local linear solves
if F.degree == 0
  if F.use_smooth_delta && F.delta == 0
    varargin = set_option(varargin,'smoothDelta',getSmoothDelta(F,v));
  end
  [vals,warnings] = evalConst(F,v,varargin{:});

  if isscalar(F)
    vals = reshape(vals,dimensions);
  else
    vals = reshape(vals,[N size(F)]);
  end
  conds = [];
  info = initRegInfo(N);
  if wantInfo, info = reshapeRegInfo(info,dimensions); end
  if emitWarnings, issueWarnings(warnings,F); end
  return
end

% the local solver needs at least two pages
if N == 1
  [vals,conds,info,warnings] = F.eval([v;v],varargin{:});
  vals = reshape(vals(1,:),size(F));
  if wantConds, conds = conds(1); end
  if wantInfo, info = sliceRegInfo(info,1); end
  if emitWarnings, issueWarnings(warnings,F); end
  return
end

% outlier indicators depend on the values, so evaluate componentwise
if ~isscalar(F) && F.detectOutliers
  v = v(:);
  vals = zeros(numel(v),numel(F));

  F1 = F.subSet(1);
  if ~isempty(F.outlierIndicators)
    F1.outlierIndicators = F.outlierIndicators(:,1);
  end
  [vals(:,1),conds,info,warnings] = F1.eval(v,varargin{:});

  for k = 2:numel(F)
    Fk = F.subSet(k);
    if size(F.outlierIndicators,2) >= k
      Fk.outlierIndicators = F.outlierIndicators(:,k);
    end
    [vals(:,k),~,~,warningsK] = Fk.eval(v,varargin{:});
    warnings = mergeWarnings(warnings,warningsK);
  end

  vals = reshape(vals,[numel(v) size(F)]);
  if wantConds, conds = reshape(conds,dimensions); end
  if wantInfo, info = reshapeRegInfo(info,dimensions); end
  if emitWarnings, issueWarnings(warnings,F); end
  return
end

vals = zeros(N,numel(F));
conds = zeros(N,1);
if wantInfo, info = initRegInfo(N); end

smoothDelta = [];
if F.delta == 0
  evalBatch = @evalKNN;
  nn = candidateCount(F);
  % the smooth support field is computed once and used by every batch
  if F.use_smooth_delta, smoothDelta = getSmoothDelta(F,v); end
else
  evalBatch = @evalRange;
  % fixed-radius neighborhoods are capped at this size
  nn = F.dim * F.oF_max;
end

% keep the large pagewise arrays close to two GiB per batch
numf = numel(F);
bytesPerCenter = (3*nn*F.dim + 7*F.dim^2 + 2*nn*numf + 2*F.dim*numf) * 8;
batchSize = max(2,floor(2 * 2^30 / max(bytesPerCenter,1)));

for first = 1:batchSize:N
  I = (first:min(first + batchSize - 1,N)).';

  options = varargin;
  if ~isempty(smoothDelta)
    options = [options(:).',{'smoothDelta'},{smoothDelta(I)}];
  end

  if wantInfo
    [vals(I,:),warningsBatch,conds(I),infoBatch] = evalBatch(F,v.subSet(I),options{:});
    info = insertRegInfo(info,I,infoBatch);
  elseif wantConds
    [vals(I,:),warningsBatch,conds(I)] = evalBatch(F,v.subSet(I),options{:});
  else
    [vals(I,:),warningsBatch] = evalBatch(F,v.subSet(I),options{:});
  end
  warnings = mergeWarnings(warnings,warningsBatch);
end

if isscalar(F)
  vals = reshape(vals,dimensions);
else
  vals = reshape(vals,[N size(F)]);
end
if wantConds, conds = reshape(conds,dimensions); end
if wantInfo, info = reshapeRegInfo(info,dimensions); end
if emitWarnings, issueWarnings(warnings,F); end

end


function delta = getSmoothDelta(F,v)
% a smooth support radius from the distances to the nn-th node on the auxiliary grid

if isempty(F.auxgrid), F = F.init_auxgrid; end

% d_n^d is proportional to the inverse local node density and hence smoother than d_n
d = F.domainDim;
mls = feval(class(F),F.auxgrid,F.auxgrid.opt.dn.^d, ...
  'degree',0,'oF',20,'centered',false,'regularize',false, ...
  'use_vor_weights',false,'use_smooth_delta',false,'weight','wendland');
mls.delta = mls.compute_delta;

delta = max(real(mls.eval(v)),0).^(1/d);

end
