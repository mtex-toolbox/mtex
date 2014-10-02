function install_mtex
% install mtex for future sessions

% get search path
cellpath = regexp(path,['(.*?)\' pathsep],'tokens');
cellpath = [cellpath{:}];

% get local path
local_path = fileparts(mfilename('fullpath'));

% check wether local_path is in search path
if ~any(strcmpi(local_path,cellpath))
  startup_mtex('noMenu')
end

if ~savepath
  disp(' ');
  disp('MTEX installation complete.');
  setappdata(0,'MTEXInstalled',true);
else
  disp(' ');
  disp('> Warning: The MATLAB search path could not be saved!');
  disp('> Save the search path manually using the MATLAB menu File -> Set Path.');
end

MTEXmenu

end

