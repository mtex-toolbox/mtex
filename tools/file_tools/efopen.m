function fid = efopen(fname,varargin)
% file open with error message

[fid,m] = fopen(fname,varargin{:});
if fid == -1
  error('mtex:nofile',['could not open: ',fname,'\n',m]);
end
