function sR = region(v,varargin)

try
  sR = v.opt.region;
catch
  sR = sphericalRegion;
end
