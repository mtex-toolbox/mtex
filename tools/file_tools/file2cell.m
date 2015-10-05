function str = file2cell(filename,maxline)
% reads a file rowise into a cellstr

if nargin == 1, maxline = inf;end

fid = efopen(filename,'r');

str = {};
while length(str) < maxline
  tline = fgetl(fid);
  if ~ischar(tline) || length(tline) > 1000, break; end
  str{end+1} = tline; %#ok<AGROW>
end

fclose(fid);
