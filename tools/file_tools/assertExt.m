function assertExt(fname,extList)

try
  [fdir,fn,ext] = fileparts(fname); %#ok<ASGLU>
  assert(any(strcmpi(ext,extList)));
catch %#ok<CTCH>
  error('Format does not match file %s',fname);
end
