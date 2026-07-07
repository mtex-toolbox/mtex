function S2F = init_reg_params(S2F, varargin)
  % initialize regularization parameters from diagnostics on auxilliary grid

  % make sure that the auxgrid exists
  if isempty(S2F.auxgrid)
    S2F = S2F.init_auxgrid;
  end

  % regularization will be turned on again at the very end of the function
  S2F.regularize = false;

  if check_option(varargin, 'info')
    reg_info = get_option(varargin, 'info');
  else
    [~, ~, reg_info] = S2F.eval(S2F.auxgrid);
  end

  % if force is true, also overwrite manually set parameters
  force = check_option(varargin, {'force', 'overwrite'});

  % fixed parameters for the automatic calibration
  goodGeometryQuantile = .50; % use best half of geometries as reference
  minLogWidth = .25;          % at least a quarter decade between min/max cond
  minRobustSigma = .25;       % avoid too narrow condition interval

  % safety clamps
  minCondFloor = 1e1;
  minCondCeil  = 1e4;
  maxCondCeil  = 1e6;
  lambdaGeomFloor = .1;
  lambdaGeomCeil  = 10;
  basisScaleFloor = 1;
  basisScaleCeil  = 10;

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
  logQ95 = getQuantile(logcondGood, .95);

  robustSigma = (logQ75 - logQ25) / 1.349;
  robustSigma = max(robustSigma, minRobustSigma);

  % choose start of condition regularization
  %   this should stay close to the typical good-geometry condition scale
  logMincond = max(logQ55, logMed + .25 * robustSigma);

  % choose full condition regularization from the measured, but non-extreme tail
  %   this avoids very large maxcond caused by a few pathological systems
  logQ80All = getQuantile(logcond, .80);
  logQ90All = getQuantile(logcond, .90);
  logMaxcond = max([logQ90, logMed + 2.25 * robustSigma, logQ80All]);

  % allow wider transition intervals only if the aux-grid conditions vary a lot
  condSpread = max(logQ90 - logQ50, 0);
  allSpread = max(logQ90All - getQuantile(logcond, .50), 0);
  spreadSeverity = max(condSpread, .5 * allSpread);
  spreadSeverity = min(max((spreadSeverity - .5) / 1.5, 0), 1);
  maxLogWidth = 1.75 + 1.25 * spreadSeverity;

  % avoid too narrow transition interval, but also avoid unreasonable maxcond
  logMaxcond = max(logMaxcond, logMincond + minLogWidth);
  logMaxcond = min(logMaxcond, logMincond + maxLogWidth);

  % safety clamps
  logMincond = min(max(logMincond, log10(minCondFloor)), log10(minCondCeil));
  logMaxcond = max(logMaxcond, logMincond + minLogWidth);
  logMaxcond = min(logMaxcond, log10(maxCondCeil));

  mincond_auto = 10.^logMincond;
  maxcond_auto = 10.^logMaxcond;

  % set mincond and maxcond, unless they were prescribed manually
  if (isempty(S2F.mincond) || force), S2F.mincond = mincond_auto; end
  if (isempty(S2F.maxcond) || force), S2F.maxcond = maxcond_auto; end

  % compute geometry quantiles
  g50 = getQuantile(geometryScore, .50);
  g90 = getQuantile(geometryScore, .90);
  g95 = getQuantile(geometryScore, .95);
  g99 = getQuantile(geometryScore, .99);

  % choose geometry regularization strength from geometry severity
  %   lambda_geom_rel acts relative to the normalized Gram scale
  geomSeverityLambda = max([g90, .9*g95, .8*g99]);
  geomSeverityLambda = min(max(geomSeverityLambda, 0), 1);

  % map severity to the empirical range:
  %   severity 0   -> lambda_geom_rel = 1
  %   severity .5  -> lambda_geom_rel = 10
  %   severity 1   -> lambda_geom_rel = 100
  lambda_geom_rel_auto = 10 .^ (2 * geomSeverityLambda);
  lambda_geom_rel_auto = min(max(lambda_geom_rel_auto, lambdaGeomFloor), lambdaGeomCeil);

  if isempty(S2F.lambda_geom_rel) || force
    S2F.lambda_geom_rel = lambda_geom_rel_auto;
  end

  % choose degree-selectivity of the regularization
  %   this should be moderate, since lambda_geom_rel controls the amount of
  %   geometry regularization
  condSeverity = max((condSpread - .75) / 2, 0);
  condSeverity = min(condSeverity, 1);

  geomSeverityBasis = max(g90, .6 * g95);
  geomSeverityBasis = min(max(geomSeverityBasis, 0), 1);

  basisSeverity = max(.85 * geomSeverityBasis, .5 * condSeverity);
  basisSeverity = min(max(basisSeverity, 0), 1);

  % map severity to [1,10]
  %   not good, but not terrible geometries should usually give values around 3-4
  basis_weights_scale_auto = 1 + 9 * basisSeverity.^1.50;
  basis_weights_scale_auto = min(max(basis_weights_scale_auto, ...
    basisScaleFloor), basisScaleCeil);

  if isempty(S2F.basis_weights_scale) || force
    S2F.basis_weights_scale = basis_weights_scale_auto;
  end

  % if we compute the reg params, actually enable regularization
  S2F.regularize = true;
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