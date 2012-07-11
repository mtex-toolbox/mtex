function cell2file(file,str,flag)
% write cellstring to file

if nargin == 2, flag = 'w'; end
fid = efopen(file,flag);

write_cell(fid,str);
fclose(fid);
