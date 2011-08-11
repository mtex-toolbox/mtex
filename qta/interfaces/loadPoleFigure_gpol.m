function pf = loadPoleFigure_gpol(fname,varargin)

fid = fopen(fname);

type =  readlinestr(fid,4);
comment = readlinestr(fid,8);

npixelb = {'uint8' 'uint16',[], 'uint32'};
bytes = npixelb{readline(fid,40)};

rows   = readline(fid,41);   %NROWS
cols   = readline(fid,42);   %NCOLS

% data
fseek(fid, 96*80, 'bof');
A = fread(fid,rows*cols,bytes);

count = [];
index = [];

while ~feof(fid)  
  c = sscanf(char(fread(fid,9,'char'))','%d');
  i = sscanf(char(fread(fid,7,'char'))','%d');
  
  if ~isempty(c) && ~isempty(i)
    count(end+1)=c;
    index(end+1)=i;
  else
    break
  end
end
fclose(fid);

A(index+1) = count;
A = (reshape(A,rows,cols))';

[ix iy data] = find(A);
ix = (ix-size(A,2)/2);
iy = (iy-size(A,2)/2);

rho = atan2(iy,ix);                            % beta
if strfind(lower(type),'stereo') 
  theta = 2*atan(ix/(size(A,2)/2).*sec(rho));  %alpha
else

end

h  = string2Miller(fname);
r = S2Grid(vector3d('polar',theta,rho)); % fix 'RESOLUTION'

pf = PoleFigure(h,r,data,symmetry('cubic'),symmetry,'comment',comment);


function data = readline(fid,line)

fseek(fid,(line-1)*80+8,'bof');
data = sscanf(char(fread(fid, 72, 'char'))','%f');

function data = readlinestr(fid,line)

fseek(fid,(line-1)*80+8,'bof');
data = char(fread(fid, 72, 'char')');


