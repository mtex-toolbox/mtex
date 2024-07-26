function display(S2G)
% standard output

displayClass(S2G,inputname(1),'moreInfo');


if strcmp(S2G.scheme,'optimal')
  disp(['  scheme: ',S2G.scheme,' (',S2G.name,')'])
  disp(['  bandwidth: ',num2str(S2G.bandwidth)])
  disp(['  grid: ',char(S2G)]);
else
  disp(['  scheme: ',S2G.scheme])
  disp(['  bandwidth: ',num2str(S2G.bandwidth)])
  disp(['  size: ' size2str(S2G)]); 
end