function write_cell(fid,cell)
% write cell string to text file

for i = 1:length(cell)
  fprintf(fid,'%s\n',cell{i});
end
