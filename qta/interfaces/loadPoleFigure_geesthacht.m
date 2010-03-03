function pf = loadPoleFigure_geesthacht(fname,varargin)
% load ptx file 
%
%% Input
%  fname - file name
%
%% Output
%  pf    - vector of @PoleFigure
%
%% See also
% interfacesPoleFigure_index geesthacht_interface loadPoleFigure

% read data
fid = efopen(fname);
d = textscan(fid,'%n %n %*n %n %n %n %*n %*n %*n %*n %*n:%*n',...
  'commentStyle','$','HeaderLines',1);
fclose(fid);

% identify data
assert(all(d{1}.'==(1:length(d{1}))));
d = {d{2:5}};
assert(~isempty(d{1})); % all items have the same length! (equal(cellfun('length',d),1))
assert(all(d{2}>=0 & d{2}<=90 & d{3}>=-370 & d{3}<=370));

pos = 1;
pf = [];
while pos <= length(d{1})
  
  npos = find(d{1}(pos)==d{1},1,'last');
  r = S2Grid(sph2vec(pi/2-d{2}(pos:npos)*degree,d{3}(pos:npos)*degree),'antipodal');
  dd = d{4}(pos:npos);
  
  pf = [pf,PoleFigure(Miller(1,0,0),r,dd,symmetry('cubic'),symmetry,varargin{:})]; %#ok<AGROW>
  pos = npos+1;  
  
end

assert(numel(r)>=5);
