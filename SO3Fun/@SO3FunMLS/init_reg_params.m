function SO3F = init_reg_params(SO3F, varargin)
  % initialize geometry- and condition-regularization parameters on the
  % deterministic equispaced auxiliary grid

  % make sure that the auxiliary grid exists
  if isempty(SO3F.auxgrid)
    SO3F = SO3F.init_auxgrid;
  end

  % evaluate unregularized local systems during calibration
  SO3F.regularize = false;

  if check_option(varargin, 'info')
    reg_info = get_option(varargin, 'info');
    numCalibrationPoints = numel(getField(reg_info, 'conds_unreg'));
  else
    % The smooth support field may require a large auxiliary grid. Condition
    % and geometry quantiles can be calibrated reliably on a deterministic
    % equispaced subset, which keeps initialization costs bounded.
    regGrid = SO3F.auxgrid;
    maxCalibrationPoints = 20000;

    if numel(regGrid) > maxCalibrationPoints
      I = unique(round(linspace(1, numel(regGrid), maxCalibrationPoints))).';
      regGrid = regGrid.subSet(I);
    end

    numCalibrationPoints = numel(regGrid);
    [~, ~, reg_info] = SO3F.eval(regGrid);
  end

  % if force is true, also overwrite manually set parameters
  force = check_option(varargin, {'force', 'overwrite'});

  % fixed parameters, matching the successful S2FunMLS calibration
  goodGeometryQuantile = .50; % best half of geometries defines the reference
  minLogWidth = .25;          % at least a quarter decade between thresholds
  minRobustSigma = .25;       % avoid an unrealistically sharp transition

  % broad but finite safety clamps
  minCondFloor = 1e1;
  minCondCeil  = 1e4;
  maxCondCeil  = 1e6;
  lambdaGeomFloor = 1;
  lambdaGeomCeil  = 3;
  basisScaleFloor = 1;
  basisScaleCeil  = 4;

  % diagnostic data
  conds_unreg = real(getField(reg_info, 'conds_unreg'));
  geometryScore = real(getField(reg_info, 'geometryScore', zeros(size(conds_unreg))));

  conds_unreg = conds_unreg(:);
  geometryScore = min(max(geometryScore(:), 0), 1);

  % remove unusable calibration values
  I = isfinite(conds_unreg) & conds_unreg >= 1 & isfinite(geometryScore);
  conds_unreg = conds_unreg(I);
  geometryScore = geometryScore(I);

  % conservative fallback for the unlikely case of empty diagnostics
  if isempty(conds_unreg)
    if isempty(SO3F.mincond) || force, SO3F.mincond = 1e2; end
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

  % robust center and scale of the good-geometry condition distribution
  logMed = median(logcondGood);
  logQ25 = getQuantile(logcondGood, .25);
  logQ50 = getQuantile(logcondGood, .50);
  logQ55 = getQuantile(logcondGood, .55);
  logQ75 = getQuantile(logcondGood, .75);
  logQ90 = getQuantile(logcondGood, .90);

  robustSigma = (logQ75 - logQ25) / 1.349;
  robustSigma = max(robustSigma, minRobustSigma);

  % start condition regularization near the upper half of well-shaped systems
  logMincond = max(logQ55, logMed + .25 * robustSigma);

  % full condition activation is determined from the measured upper tail
  logQ50All = getQuantile(logcond, .50);
  logQ80All = getQuantile(logcond, .80);
  logQ90All = getQuantile(logcond, .90);
  logMaxcond = max([logQ90, logMed + 2.25 * robustSigma, logQ80All]);

  % allow a wider transition only for a genuinely broad distribution
  condSpread = max(logQ90 - logQ50, 0);
  allSpread = max(logQ90All - logQ50All, 0);
  spreadSeverity = max(condSpread, .5 * allSpread);
  spreadSeverity = min(max((spreadSeverity - .5) / 1.5, 0), 1);
  maxLogWidth = 1.75 + 1.25 * spreadSeverity;

  logMaxcond = max(logMaxcond, logMincond + minLogWidth);
  logMaxcond = min(logMaxcond, logMincond + maxLogWidth);

  % safety clamps
  logMincond = min(max(logMincond, log10(minCondFloor)), log10(minCondCeil));
  logMaxcond = max(logMaxcond, logMincond + minLogWidth);
  logMaxcond = min(logMaxcond, log10(maxCondCeil));

  mincond_auto = 10.^logMincond;
  maxcond_auto = 10.^logMaxcond;

  if isempty(SO3F.mincond) || force, SO3F.mincond = mincond_auto; end
  if isempty(SO3F.maxcond) || force, SO3F.maxcond = maxcond_auto; end

  % geometry strength from the upper tail of the normalized SO(3) score.
  % lambda_geom_rel is now a multiplier of the fraction of condition-derived
  % stabilization assigned to geometry. Values around one are the natural scale.
  g50 = getQuantile(geometryScore, .50);
  g90 = getQuantile(geometryScore, .90);
  g95 = getQuantile(geometryScore, .95);
  g99 = getQuantile(geometryScore, .99);

  geomSeverityLambda = max([g90, .8 * g95, .6 * g99]);
  geomSeverityLambda = min(max(geomSeverityLambda, 0), 1);

  lambda_geom_rel_auto = 1 + 2 * geomSeverityLambda;
  lambda_geom_rel_auto = min(max(lambda_geom_rel_auto, ...
    lambdaGeomFloor), lambdaGeomCeil);

  if isempty(SO3F.lambda_geom_rel) || force
    SO3F.lambda_geom_rel = lambda_geom_rel_auto;
  end

  % Keep the degree selectivity moderate. A noisy geometry score should not
  % simultaneously create a large ridge and an extreme penalty profile.
  condSeverity = max((condSpread - .75) / 2, 0);
  condSeverity = min(condSeverity, 1);

  geomSeverityBasis = max(g90, .6 * g95);
  geomSeverityBasis = min(max(geomSeverityBasis, 0), 1);

  basisSeverity = max(.5 * geomSeverityBasis, .5 * condSeverity);
  basisSeverity = min(max(basisSeverity, 0), 1);

  basis_weights_scale_auto = 1 + 3 * basisSeverity.^1.5;
  basis_weights_scale_auto = min(max(basis_weights_scale_auto, ...
    basisScaleFloor), basisScaleCeil);

  if isempty(SO3F.basis_weights_scale) || force
    SO3F.basis_weights_scale = basis_weights_scale_auto;
  end

  % retain the calibration values on the auxiliary grid for inspection
  calibration = struct;
  calibration.numPoints = numCalibrationPoints;
  calibration.geometryCut = gCut;
  calibration.logConditionMedian = logMed;
  calibration.logConditionQ25 = logQ25;
  calibration.logConditionQ75 = logQ75;
  calibration.logConditionQ90 = logQ90;
  calibration.robustSigma = robustSigma;
  calibration.geometryQ50 = g50;
  calibration.geometryQ90 = g90;
  calibration.geometryQ95 = g95;
  calibration.geometryQ99 = g99;
  calibration.mincond = SO3F.mincond;
  calibration.maxcond = SO3F.maxcond;
  calibration.lambda_geom_rel = SO3F.lambda_geom_rel;
  calibration.basis_weights_scale = SO3F.basis_weights_scale;
  SO3F.auxgrid.opt.regCalibration = calibration;

  SO3F.regularize = true;
end


% additional functions

% get field from struct, allowing several possible names
function value = getField(S, names, default)
  if ischar(names) || isstring(names)
    names = cellstr(names);
  end

  for k = 1:numel(names)
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

% compute linearly interpolated sample quantiles
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
