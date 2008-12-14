function display(S1G)
% standart output

disp(' ');
disp([inputname(1) ' = ']);
disp(' ');
disp(['  S1Grid: ' char(check_option(S1G(1)))]);
for i=1:length(S1G)
  disp(['   (' num2str(i) ...
    ') ' num2str(GridLength(S1G(i))) ' points,', ...
    ' min: ',num2str([S1G(i).min]) ...
    ', max: ',num2str([S1G(i).max]) ...  
    ', res.: ',num2str(getResolution(S1G(i)))]);
end 
disp(' ');