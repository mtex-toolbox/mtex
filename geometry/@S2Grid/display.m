function display(S2G)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('S2Grid_index','S2Grid') ...
  ' ' docmethods(inputname(1))]);

display@vector3d(S2G,'skipHeader');
