function sR = region(v,varargin)

% the region a direction lives in may be asked for as the sector the group
% of its frame reduces the sphere to
if hasSymmetry(v) && ~check_option(varargin,'complete') && ...
    check_option(varargin,{'fundamentalRegion','fundamentalSector'})
  sR = v.frame.fundamentalSector(varargin{:});
  return
end

try
  sR = v.opt.region;
catch
  sR = sphericalRegion;
  sR.antipodal = v.antipodal;
end
