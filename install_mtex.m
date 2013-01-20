function install_mtex
% install mtex for future sessions

if ~ispref('mtex')
  startup_mtex('noMenu')
end

if ~savepath
  disp('> MTEX installation complete.');
  setappdata(0,'MTEXInstalled',true);
else
  disp(' ');
  disp('> Warning: The MATLAB search path could not be saved!');
  disp('> Save the search path manually using the MATLAB menu File -> Set Path.');
end

MTEXmenu

end

