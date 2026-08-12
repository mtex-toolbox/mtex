function SO3F = init_reg_params(SO3F, varargin)
% initialize the goal-oriented regularization parameters on an SO(3) grid

if SO3F.degree == 0
  SO3F.regularize = false;
  return;
end

if isempty(SO3F.auxgrid)
  SO3F = SO3F.init_auxgrid;
end

if check_option(varargin, 'info')
  reg_info = get_option(varargin, 'info');
  numCalibrationPoints = numel(reg_info.centerAmplification);
else
  % Calibration depends only on nodes, basis, and local weights. Use one
  % function component and a moderate deterministic subset of the auxiliary grid.
  calibrationF = SO3F;
  if ~isscalar(calibrationF)
    calibrationF = calibrationF.subSet(1);
  end
  calibrationF.regularize = false;

  regGrid = SO3F.auxgrid;
  nCalibration = min(numel(regGrid), ...
    max(1500, min(3000, 30 * SO3F.dim)));
  if numel(regGrid) > nCalibration
    I = unique(round(linspace(1, numel(regGrid), nCalibration))).';
    regGrid = regGrid.subSet(I);
  end

  numCalibrationPoints = numel(regGrid);
  [~, ~, reg_info, ~] = calibrationF.eval(regGrid);
end

force = check_option(varargin, {'force', 'overwrite'});

% Assigning mincond also updates targetcond for backward compatibility. Record
% the user choices before changing any of the three parameters.
setMincond = isempty(SO3F.mincond) || force;
setMaxcond = isempty(SO3F.maxcond) || force;
setTargetcond = isempty(SO3F.targetcond) || force;
manualTargetcond = SO3F.targetcond;

amp = real(reg_info.centerAmplification(:));
amp = amp(isfinite(amp) & amp >= 1);

% The indicator is normalized, so the same two robust regimes used on S2 have
% the same interpretation on SO(3).
strongBulkThreshold = 1e2;

mildOnsetAmp = 30;
mildFullAmp = 1e3;
mildTargetAmp = 30;

strongOnsetAmp = 10;
strongFullAmp = 300;
strongTargetAmp = 10;

if isempty(amp)
  q80 = mildOnsetAmp;
else
  q80 = getQuantile(amp, .80);
end

if q80 >= strongBulkThreshold
  mincond_auto = strongOnsetAmp;
  maxcond_auto = strongFullAmp;
  targetcond_auto = strongTargetAmp;
else
  mincond_auto = mildOnsetAmp;
  maxcond_auto = mildFullAmp;
  targetcond_auto = mildTargetAmp;
end

if setMincond, SO3F.mincond = mincond_auto; end
if setMaxcond, SO3F.maxcond = maxcond_auto; end
if setTargetcond
  SO3F.targetcond = targetcond_auto;
else
  SO3F.targetcond = manualTargetcond;
end

if SO3F.mincond < 1
  error('mincond must be at least 1.');
end
if SO3F.targetcond < 1 || SO3F.targetcond > SO3F.mincond
  error('targetcond must satisfy 1 <= targetcond <= mincond.');
end
if SO3F.maxcond <= SO3F.mincond
  error('maxcond must be strictly larger than mincond.');
end

calibration = struct;
calibration.numPoints = numCalibrationPoints;
calibration.amplificationQ80 = q80;
calibration.mincond = SO3F.mincond;
calibration.maxcond = SO3F.maxcond;
calibration.targetcond = SO3F.targetcond;
SO3F.auxgrid.opt.regCalibration = calibration;

SO3F.regularize = true;

end


function q = getQuantile(x, p)
  x = sort(x(:));
  x = x(isfinite(x));

  if isempty(x)
    q = NaN;
    return;
  end
  if numel(x) == 1
    q = x;
    return;
  end

  p = min(max(p, 0), 1);
  pos = 1 + (numel(x) - 1) * p;
  lo = floor(pos);
  hi = ceil(pos);

  if lo == hi
    q = x(lo);
  else
    a = pos - lo;
    q = (1-a) * x(lo) + a * x(hi);
  end
end
