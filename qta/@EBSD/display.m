function display(ebsd)
% standard output

disp(' ');
if ~isempty(ebsd(1).comment)
  disp(ebsd(1).comment);
  disp(repmat('-',1,length(ebsd(1).comment)));
else
  disp([inputname(1),' = EBSD data',]);
end

if ~isempty(fields(ebsd(1).options))
  disp([' properties: ',option2str(fields(ebsd(1).options))]);
end
for i = 1:length(ebsd)
  disp([' ' char(ebsd(i))]);
end
