function sR = region(v,varargin)

try
  sR = v.opt.region;
catch
  sR = sphericalRegion;
  sR.antipodal = v.antipodal;
end
