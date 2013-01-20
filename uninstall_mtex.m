function uninstall_mtex
% remove mtex for use in future sessions

cellpath = regexp(path,['(.*?)\' pathsep],'tokens');
cellpath = [cellpath{:}];

cellpath = cellpath(~cellfun('isempty',strfind(cellpath,getMTEXpref('mtexPath'))));
rmpath(cellpath{:});

if ~savepath
  disp('MTEX unistalled!');
  setappdata(0,'MTEXInstalled',false);
else

  disp('> Warning: The MATLAB search path could not be saved!');
  disp('> Save the search path manually using the MATLAB menu File -> Set Path.');

end
