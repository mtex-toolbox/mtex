function ebsd = updateUnitCell(ebsd,uc,varargin)
% this function should be called after the spatial coordinates of an EBSD
% data set have been modified
%
% Options
%  hint - a candidate unit cell (e.g. derived from a file's own header
%         step size). calcUnitCell's statistical position-based estimate
%         is always computed as the baseline/fallback; the hint is
%         preferred over it whenever the estimate cannot contradict it -
%         either because the estimate itself is calcUnitCell's known
%         degenerate placeholder (regularPoly(4,1,0): a fixed size of 1
%         regardless of the real data, produced when some vendors' raw
%         per-pixel position data is not in physical units at all, e.g.
%         beam/pixel indices), or because it agrees with the hint.

if nargin > 1 && ~isempty(uc)
  % 1. an explicit unit cell always wins, no further checks
  ebsd = setUnitCell(ebsd,uc);
  return
end

% 3. compute from scratch - always run as the baseline/fallback, since
% comparing a hint against a cheap independent re-estimate risks subtly
% diverging from calcUnitCell's own (more elaborate) internal logic
uc = calcUnitCell(ebsd.pos.xyz);

hint = get_option(varargin,'hint');
if ~isempty(hint)
  % 2. prefer the hint unless the estimate is well-defined and actively
  % disagrees with it
  isPlaceholder = ~isempty(uc) && abs(mean(norm(vector3d(uc(:,1),uc(:,2),0))) - sqrt(2)/2) < 1e-9;

  if isempty(uc) || isPlaceholder
    uc = hint;
  else
    dEst = mean(norm(vector3d(uc(:,1),uc(:,2),0)));
    dHint = mean(norm(hint));
    if dEst > 0 && abs(dEst - dHint) / dEst <= 0.05
      uc = hint;
    else
      warning('MTEX:unitCellMismatch', ...
        ['the header step size does not match the measured pixel spacing ' ...
        '(header: %.4g, estimated: %.4g); keeping the position-based unit cell.'], ...
        dHint, dEst);
    end
  end
end

ebsd = setUnitCell(ebsd,uc);

end

function ebsd = setUnitCell(ebsd,uc)

if isempty(uc)
  uc = vector3d;
elseif ~isa(uc,'vector3d')
  uc = vector3d(uc(:,1),uc(:,2),0);
end

ebsd.unitCell = uc;

end
