function S2F = init_reg_params(S2F, varargin)
% initialize the goal-oriented regularization parameters on a random grid

if S2F.degree == 0
  S2F.regularize = false;
  return;
end

% Smooth delta and regularization deliberately use different grids.
if S2F.use_smooth_delta && (S2F.delta == 0) && isempty(S2F.auxgrid)
  S2F = S2F.init_auxgrid;
end
if isempty(S2F.reg_auxgrid)
  S2F = S2F.init_reg_auxgrid;
end

if check_option(varargin, 'info')
  reg_info = get_option(varargin, 'info');
else
  % Calibration depends only on nodes, basis, and weights. Use one function
  % component so a multi-right-hand-side object does not make construction slower.
  calibrationF = S2F;
  if ~isscalar(calibrationF)
    calibrationF = calibrationF.subSet(1);
  end
  calibrationF.regularize = false;
  [~, ~, reg_info] = calibrationF.eval(S2F.reg_auxgrid);
end

force = check_option(varargin, {'force', 'overwrite'});

% Record which values have actually been prescribed by the user. Assigning
% mincond also updates targetcond for backward compatibility, so these flags
% have to be stored before any parameter is changed below.
setMincond = isempty(S2F.mincond) || force;
setMaxcond = isempty(S2F.maxcond) || force;
setTargetcond = isempty(S2F.targetcond) || force;
manualTargetcond = S2F.targetcond;

amp = getField(reg_info, ...
  {'centerAmplification', 'center_amplification'});
amp = real(amp(:));
amp = amp(isfinite(amp) & amp >= 1);

% The benchmark showed two clearly separated situations:
%   - ordinary node sets have a healthy bulk and only exceptional bad tails;
%   - globally unstable node sets already have large amplification in the
%     upper part of the bulk and need both an earlier onset and a stronger
%     final correction.
% We therefore use only two fixed regimes and let one robust quantile choose
% between them. This avoids fitting several thresholds to the calibration data.
strongBulkThreshold = 1e2;

% Mild regime: leave normal random and well-distributed neighborhoods nearly
% untouched, but still regularize isolated catastrophic systems.
mildOnsetAmp = 30;
mildFullAmp = 1e3;
mildTargetAmp = 30;

% Strong regime: if instability affects at least the upper fifth of the bulk,
% start correcting earlier and reach the target on a shorter logarithmic scale.
% The interval 10--300 is deliberately less aggressive than 10--100.
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

if setMincond
  S2F.mincond = mincond_auto;
end
if setMaxcond
  S2F.maxcond = maxcond_auto;
end
if setTargetcond
  S2F.targetcond = targetcond_auto;
else
  % Restore an explicitly prescribed target if mincond was assigned above.
  S2F.targetcond = manualTargetcond;
end

% Broad safety bounds are retained for manual choices. mincond is the onset,
% maxcond is the full-activation threshold, and targetcond is the amplification
% approached at full strength. The target may be lower than the onset.
minLogGap = 1;
maxLogGap = 4;

minAmpFloor = 1.1;
minAmpCeil = 1e4;
maxAmpFloor = 1e2;
maxAmpCeil = 1e7;

logMincond = log10(max(real(S2F.mincond), minAmpFloor));
logMaxcond = log10(max(real(S2F.maxcond), minAmpFloor));

logMincond = min(max(logMincond, log10(minAmpFloor)), log10(minAmpCeil));
logMaxcond = min(max(logMaxcond, log10(maxAmpFloor)), log10(maxAmpCeil));
logMaxcond = max(logMaxcond, logMincond + minLogGap);
logMaxcond = min(logMaxcond, logMincond + maxLogGap);
logMaxcond = min(logMaxcond, log10(maxAmpCeil));

% Assigning mincond also updates targetcond. Preserve the independently chosen
% target across the final normalization of the transition parameters.
targetcond = S2F.targetcond;
S2F.mincond = 10.^logMincond;
S2F.maxcond = 10.^logMaxcond;
S2F.targetcond = min(max(real(targetcond), minAmpFloor), S2F.mincond);
S2F.regularize = true;

end


% get a field from a struct, allowing several names
function value = getField(S, names)
  if ischar(names) || isstring(names)
    names = cellstr(names);
  end

  for k = 1 : numel(names)
    if isfield(S, names{k})
      value = S.(names{k});
      return;
    end
  end

  error('Required field is missing in regularization diagnostics.');
end

% compute linearly interpolated quantiles without a toolbox dependency
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
