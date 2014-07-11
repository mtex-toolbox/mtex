function assertExtension(fname,varargin)

try
  [fdir,fn,fext] = fileparts(fname);
  assert(any(strcmpi(fext,varargin)));
catch
  interfaceError(fname);
end