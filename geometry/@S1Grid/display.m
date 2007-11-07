function display(S1G)
% standart output

disp(['S1Grid, ',check_option(S1G(1))]);

disp(['min:        ',num2str([S1G.min])]);
disp(['max:        ',num2str([S1G.max])]);
disp(['points:     ',num2str(GridLength(S1G))]);
disp(['resolution: ',num2str(getResolution(S1G))]);
 