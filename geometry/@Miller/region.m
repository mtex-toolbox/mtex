function sR = region(m,varargin)
% return spherical region associated to a set of crystal directions

if check_option(varargin,{'fundamentalRegion','fundamentalSector'}) ...
    && ~check_option(varargin,'complete')
  sR = m.CS.fundamentalSector(varargin{:});
else
  sR = region@vector3d(m,varargin{:});
end

end
