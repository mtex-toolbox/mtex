function str = file2cell(filename)
% reads a file rowise into a cellstr

fid = efopen(filename,'r');

str = {};
while 1
  tline = fgetl(fid);
  if ~ischar(tline), break; end
  str{end+1} = tline;
end

fclose(fid);
