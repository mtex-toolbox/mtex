function display(ebsd)
% standard output

disp(' ');
disp([inputname(1) ' = ']);
disp(' ');

disp(['  EBSD: ' ebsd.comment ]);
for n=1:numel(ebsd)
  so3 = ebsd.orientations(n);
  disp(['   (' num2str(n) ') ' ...
    char(getCSym(so3)) '/' char(getSSym(so3)) ': ' ...
    char(so3)]);
end
disp(' ');
