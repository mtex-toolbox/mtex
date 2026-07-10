function SO3F = init_reg_params(SO3F, varargin)
  % initialize regularization parameters from diagnostics on auxilliary grid

  % make sure that the auxgrid exists
  if isempty(SO3F.auxgrid)
    SO3F = SO3F.init_auxgrid;
  end

  % regularization will be turned on again at the very end of the function
  SO3F.regularize = false;

  if check_option(varargin, 'info')
    reg_info = get_option(varargin, 'info');
  else
    % the smooth-delta field may require a large auxiliary grid, whereas the
    %   regularization quantiles can be estimated reliably from a smaller subset
    regGrid = SO3F.auxgrid;
    maxCalibrationPoints = 20000;

    if numel(regGrid) > maxCalibrationPoints
      I = unique(round(linspace(1, numel(regGrid), maxCalibrationPoints))).';
      regGrid = regGrid.subSet(I);
    end

    [~, ~, reg_info] = SO3F.eval(regGrid);
  end

  % if force is true, also overwrite manually set parameters
  force = check_option(varargin, {'force', 'overwrite'});

  % fixed parameters for the automatic calibration
  goodGeometryQuantile = .50; % use best half of geometries as reference
  minLogWidth = .75;          % avoid a very abrupt regularization transition
  minRobustSigma = .25;       % avoid too narrow condition intervals

  % safety clamps
  % these are close to the S2 ranges, with a moderately larger upper condition
  %   range for the larger local ansatz spaces on SO(3)
  minCondFloor = 50;
  minCondCeil  = 1e5;
  maxCondCeil  = 1e7;
  lambdaGeomFloor = 0;
  lambdaGeomCeil  = 2;
  basisScaleFloor = 0;
  basisScaleCeil  = 2;

  % diagnostic data
  conds_unreg = getField(reg_info, 'conds_unreg');
  geometryScore = getField(reg_info, 'geometryScore', zeros(size(conds_unreg)));

  % reshape and make sure the values are in the expected range
  conds_unreg = real(conds_unreg(:));
  geometryScore = real(geometryScore(:));
  geometryScore = min(max(geometryScore, 0), 1);

  % remove unusable calibration values
  I = isfinite(conds_unreg) & conds_unreg >= 1 & isfinite(geometryScore);
  conds_unreg = conds_unreg(I);
  geometryScore = geometryScore(I);

  % fallback for the unlikely case that no usable diagnostics are available
  if isempty(conds_unreg)
    if isempty(SO3F.mincond) || force, SO3F.mincond = 300; end
    if isempty(SO3F.maxcond) || force, SO3F.maxcond = 1e4; end
    if isempty(SO3F.lambda_geom_rel) || force, SO3F.lambda_geom_rel = 1; end
    if isempty(SO3F.basis_weights_scale) || force, SO3F.basis_weights_scale = 1; end
    SO3F.regularize = true;
    return;
  end

  % work with logarithmic condition numbers
  logcond = log10(conds_unreg);

  % use geometrically good systems as reference for condition thresholds
  gCut = getQuantile(geometryScore, goodGeometryQuantile);
  good = geometryScore <= gCut;

  % if the filter is too strict, fall back to all calibration systems
  minGood = min(100, max(10, round(.2 * numel(good))));
  if nnz(good) < minGood
    good = true(size(good));
  end
  logcondGood = logcond(good);

  % robust center and scale of the good-condition distribution
  logMed = median(logcondGood);
  logQ25 = getQuantile(logcondGood, .25);
  logQ50 = getQuantile(logcondGood, .50);
  logQ55 = getQuantile(logcondGood, .55);
  logQ75 = getQuantile(logcondGood, .75);
  logQ80 = getQuantile(logcondGood, .80);
  logQ90 = getQuantile(logcondGood, .90);

  robustSigma = (logQ75 - logQ25) / 1.349;
  robustSigma = max(robustSigma, minRobustSigma);

  % choose start of condition regularization near the typical upper half of
  %   well-shaped local systems
  logMincond = max(logQ55, logMed + .25 * robustSigma);

  % choose full condition regularization from the measured non-extreme tail
  logQ80All = getQuantile(logcond, .80);
  logQ90All = getQuantile(logcond, .90);
  logMaxcond = max([logQ90, logMed + 2.25 * robustSigma, logQ80All]);

  % allow wider transition intervals only if the condition distribution is broad
  condSpread = max(logQ90 - logQ50, 0);
  allSpread = max(logQ90All - getQuantile(logcond, .50), 0);
  spreadSeverity = max(condSpread, .5 * allSpread);
  spreadSeverity = min(max((spreadSeverity - .5) / 1.5, 0), 1);
  maxLogWidth = 1.75 + 1.25 * spreadSeverity;

  % avoid too narrow or unnecessarily wide transition intervals
  logMaxcond = max(logMaxcond, logMincond + minLogWidth);
  logMaxcond = min(logMaxcond, logMincond + maxLogWidth);

  % safety clamps
  logMincond = min(max(logMincond, log10(minCondFloor)), log10(minCondCeil));
  logMaxcond = max(logMaxcond, logMincond + minLogWidth);
  logMaxcond = min(logMaxcond, log10(maxCondCeil));

  mincond_auto = 10.^logMincond;
  maxcond_auto = 10.^logMaxcond;

  % set mincond and maxcond, unless they were prescribed manually
  if (isempty(SO3F.mincond) || force), SO3F.mincond = mincond_auto; end
  if (isempty(SO3F.maxcond) || force), SO3F.maxcond = maxcond_auto; end

  % compute geometry quantiles
  g90 = getQuantile(geometryScore, .90);
  g95 = getQuantile(geometryScore, .95);
  g99 = getQuantile(geometryScore, .99);

  % lambda_geom_rel multiplies geometryScore directly; values around one are
  %   therefore the natural scale, while values up to two allow stronger action
  %   for consistently poor local geometries
  geomSeverity = max([g90, .9 * g95, .75 * g99]);
  geomSeverity = min(max(geomSeverity, 0), 1);

  lambda_geom_rel_auto = 1 + geomSeverity;
  lambda_geom_rel_auto = min(max(lambda_geom_rel_auto, ...
    lambdaGeomFloor), lambdaGeomCeil);

  if isempty(SO3F.lambda_geom_rel) || force
    SO3F.lambda_geom_rel = lambda_geom_rel_auto;
  end

  % basis_weights_scale changes the degree selectivity of the ridge profile;
  %   one is a moderate default and the automatic range stays close to it
  condSeverity = max((condSpread - .75) / 2, 0);
  condSeverity = min(condSeverity, 1);
  degreeSeverity = min(max((SO3F.degree - 2) / 4, 0), 1);
  basisSeverity = max(condSeverity, .5 * degreeSeverity);

  basis_weights_scale_auto = 1 + basisSeverity.^1.5;
  basis_weights_scale_auto = min(max(basis_weights_scale_auto, ...
    basisScaleFloor), basisScaleCeil);

  if isempty(SO3F.basis_weights_scale) || force
    SO3F.basis_weights_scale = basis_weights_scale_auto;
  end

  % if we compute the reg params, actually enable regularization
  SO3F.regularize = true;
end


% additional functions

% get field from struct, allowing several possible names
function value = getField(S, names, default)
  if ischar(names) || isstring(names)
    names = cellstr(names);
  end

  for k = 1 : numel(names)
    if isfield(S, names{k})
      value = S.(names{k});
      return;
    end
  end

  if nargin >= 3
    value = default;
  else
    error('Required field is missing in regularization diagnostics.');
  end
end

% compute quantiles
function q = getQuantile(x, p)
  x = sort(x(:));
  x = x(isfinite(x));

  if isempty(x)
    q = NaN;
    return;
  end

  n = numel(x);
  if n == 1
    q = x;
    return;
  end

  p = min(max(p, 0), 1);
  pos = 1 + (n - 1) * p;

  lo = floor(pos);
  hi = ceil(pos);

  if lo == hi
    q = x(lo);
  else
    a = pos - lo;
    q = (1 - a) * x(lo) + a * x(hi);
  end
end
