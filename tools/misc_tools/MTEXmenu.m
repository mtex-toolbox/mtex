function MTEXmenu
% show up MTEX menu

try
  g = getGitInfo;
  v = ['MTEX (' g.branch ')'];
catch
  v = getMTEXpref('version');
end

disp(' ');
if isempty(javachk('desktop'))
  if verLessThan('matlab','7.13')
    s = v;
  else
    s = ['<strong>' v '</strong>'];
  end
  disp([ s  ...
    ' (<a href="matlab:MTEXdoc">show documentation</a>)'])
  disp('  <a href="matlab:import_wizard(''PoleFigure'')">Import pole figure data</a>')
  disp('  <a href="matlab:import_wizard(''EBSD'')">Import EBSD data</a>')
  disp('  <a href="matlab:import_wizard(''ODF'')">Import ODF data</a>')
  disp(' ');
  
  if isappdata(0,'MTEXInstalled') && getappdata(0,'MTEXInstalled')
    disp('  <a href="matlab:uninstall_mtex">Uninstall MTEX</a>')
    disp(' ');
  else
    disp('  <a href="matlab:install_mtex">Install MTEX for future sessions</a>')
    disp(' ');
  end

end
