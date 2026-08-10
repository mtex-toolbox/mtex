function S2F = init_reg_params(S2F, varargin)
% initialize the conservative goal-oriented parameters on a random grid

if S2F.degree == 0
  S2F.regularize = false;
  return;
end

if S2F.use_smooth_delta && (S2F.delta == 0) && isempty(S2F.auxgrid)
  S2F = S2F.init_auxgrid;
end
if isempty(S2F.reg_auxgrid)
  S2F = S2F.init_reg_auxgrid;
end

if check_option(varargin, 'info')
  reg_info = get_option(varargin, 'info');
else
  calibrationF = S2F;
  if ~isscalar(calibrationF)
    calibrationF = calibrationF.subSet(1);
  end
  calibrationF.regularize = false;
  [~, ~, reg_info] = calibrationF.eval(S2F.reg_auxgrid);
end

force = check_option(varargin, {'force', 'overwrite'});
setMincond = isempty(S2F.mincond) || force;
setMaxcond = isempty(S2F.maxcond) || force;
setTargetcond = isempty(S2F.targetcond) || force;
manualTargetcond = S2F.targetcond;

amp = getField(reg_info, ...
  {'centerAmplification', 'center_amplification'});
amp = real(amp(:));
amp = amp(isfinite(amp) & amp >= 1);

% Two robust automatic regimes.
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

if setMincond, S2F.mincond = mincond_auto; end
if setMaxcond, S2F.maxcond = maxcond_auto; end
if setTargetcond
  S2F.targetcond = targetcond_auto;
else
  % Assigning mincond also assigns targetcond; restore an explicit target.
  S2F.targetcond = manualTargetcond;
end

% Respect manual values. In particular, do not silently enlarge the transition
% interval or replace the limiting target one by 1.1.
if S2F.mincond < 1
  error('mincond must be at least 1.');
end
if S2F.maxcond <= S2F.mincond
  error('maxcond must be strictly larger than mincond.');
end
if S2F.targetcond < 1 || S2F.targetcond > S2F.mincond
  error('targetcond must satisfy 1 <= targetcond <= mincond.');
end

S2F.regularize = true;

end


function value = getField(S, names)
  if ischar(names) || isstring(names), names = cellstr(names); end

  for k = 1 : numel(names)
    if isfield(S, names{k})
      value = S.(names{k});
      return;
    end
  end

  error('Required field is missing in regularization diagnostics.');
end


function q = getQuantile(x, p)
  x = sort(x(:));
  x = x(isfinite(x));

  if isempty(x), q = NaN; return; end
  if numel(x) == 1, q = x; return; end

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
