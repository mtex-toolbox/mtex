function MTEXmenu
% show up MTEX menu

% branch name, where .git is a file pointing to the git dir in a worktree
try
  g = fullfile(mtex_path,'.git');
  if ~isfolder(g), g = strtrim(extractAfter(fileread(g),'gitdir:')); end
  b = regexp(fileread(fullfile(g,'HEAD')),'refs/heads/(\S+)','tokens','once');
  v = ['MTEX (' b{1} ')'];
catch
  v = getMTEXpref('version');
end

disp(' ');
if desktop('-inuse')
  if verLessThan('matlab','7.13')
    s = v;
  else
    s = ['<strong>' v '</strong>'];
  end
  disp([ s  ...
    ' (<a href="matlab:MTEXdoc">show documentation</a>)'])
  disp('  <a href="matlab:import_wizard_old(''PoleFigure'')">Import pole figure data</a>')
  disp('  <a href="matlab:import_wizard">Import EBSD data</a>')
  disp('  <a href="matlab:check_mex">Check Installation</a>')
  disp(' ');
  
  if isappdata(0,'MTEXInstalled') && getappdata(0,'MTEXInstalled')
    disp('  <a href="matlab:uninstall_mtex">Uninstall MTEX</a>')
    disp(' ');
  else
    disp('  <a href="matlab:install_mtex">Install MTEX for future sessions</a>')
    disp(' ');
  end

end
