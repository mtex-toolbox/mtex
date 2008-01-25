function display(ebsd)
% standard output

disp(' ');
if ~isempty(ebsd(1).comment)
  disp(ebsd(1).comment);
  disp(repmat('-',1,length(ebsd(1).comment)));
else
  disp([inputname(1),' = EBSD data',]);
end
disp([' symmetry: ',char(ebsd(1).CS),' - ',char(ebsd(1).SS)]);
for i = 1:length(ebsd)
  disp([' ' char(ebsd(i))]);
end
