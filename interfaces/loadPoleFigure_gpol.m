function pf = loadPoleFigure_gpol(fname,varargin)

fid = fopen(fname);

try
  type    = readlinestr(fid,4);
  comment = readlinestr(fid,8);
  
  bytes   = 8*readline(fid,40);
  
  rows    = readline(fid,41);   %NROWS
  cols    = readline(fid,42);   %NCOLS
  
  % data
  fseek(fid, (96*80), 'bof');
  A = fread(fid,rows*cols,['uint' num2str(bytes)]);
  n = nnz(A == 2^bytes-1);      % number of overflow table elements
  
  overflow = fread(fid,'char')';  
  s2n = @(p) sscanf(char(overflow(p)),'%d');
  intensity = zeros(n,1);  position  = zeros(n,1);

  for k=1:n
    intensity(k) = s2n( (k-1)*16 + (1:9)   );
    position(k)  = s2n( (k-1)*16 + (10:16) ) + 1;
  end
  
catch
 	interfaceError(fname,fid);
end
fclose(fid);

d = A(position) == 2^bytes-1;
A(position(d)) = intensity(d);

[ix iy data] = find(reshape(A,rows,cols));
ix = (ix-cols/2-.5);
iy = (iy-rows/2-.5);

rho = -atan2(iy,ix);                          % beta
if strfind(lower(type),'stereo')
  theta = 2*atan(sqrt(ix.^2+iy.^2)./(rows/2-1));
else  % other projections
  
end

r = vector3d.byPolar(theta,rho,'antipodal');

h  = string2Miller(fname);
pf = PoleFigure(h,r,data,'comment',comment,varargin{:});


function data = readline(fid,line)

fseek(fid,(line-1)*80+8,'bof');
data = sscanf(char(fread(fid, 72, 'char'))','%f');

function data = readlinestr(fid,line)

fseek(fid,(line-1)*80+8,'bof');
data = char(fread(fid, 72, 'char')');


