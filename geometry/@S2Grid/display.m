function display(S2G)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('S2Grid_index','S2Grid') ', points: ',...
  char(S2G),', ',char(option2str(S2G.options))]);
disp(' ');
