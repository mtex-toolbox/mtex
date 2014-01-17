function restrictEBSD_ang(inFile,outFile,varargin)

% read file header
hl = file2cell(inFile,1000);

% number of header lines
nh = find(strmatch('#',hl),1,'last');

% write header to the new file
cell2file(outFile,hl(1:nh));

% read data
d = txt2mat(inFile);

x = d(:,4);
y = d(:,5);

ux = unique(x);
uy = unique(y);

s = get_option(varargin,'subSample',1);

ux = ux(1:s:end);
uy = uy(1:s:end);

ind = any(bsxfun(@eq,x,ux.'),2);
ind = ind & any(bsxfun(@eq,y,uy.'),2);

r = get_option(varargin,'region',[min(ux),min(uy),max(ux),max(uy)]);

ind = ind & x >= r(1) & x <= r(3) & y >= r(2) & y <= r(4);

d = d(ind,:);

fid = fopen(outFile,'a');

fprintf(fid,'%8.5f %8.5f %8.5f %5.1f %5.1f %d %5.3f %d %d %5.3f\n',d.');

fclose(fid);
