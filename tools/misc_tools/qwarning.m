function qwarning(s)
% warning with option to stop

disp('To interrupt press Ctr-C');
warning(s);
pause;
