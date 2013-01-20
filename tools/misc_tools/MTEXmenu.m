function MTEXmenu
% show up MTEX menu

disp(' ');
if isempty(javachk('desktop'))
  disp('Basic tasks:')
  disp('- <a href="matlab:MTEXdoc(''mtex'')">Show MTEX documentation</a>')
  disp('- <a href="matlab:import_wizard(''PoleFigure'')">Import pole figure data</a>')
  disp('- <a href="matlab:import_wizard(''EBSD'')">Import EBSD data</a>')
  disp('- <a href="matlab:import_wizard(''ODF'')">Import ODF data</a>')

  if isappdata(0,'MTEXInstalled') && getappdata(0,'MTEXInstalled')
    disp('- <a href="matlab:uninstall_mtex">Uninstall MTEX</a>')
  else
    disp('- <a href="matlab:install_mtex">Install MTEX for future sessions</a>')
  end

  disp(' ');

end
