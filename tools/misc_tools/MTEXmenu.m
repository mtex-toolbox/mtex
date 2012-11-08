function MTEXmenu
% show up MTEX menu

disp(' ');
if isempty(javachk('desktop'))
  disp('Basic tasks:')
  disp('- <a href="matlab:doc(''mtex'',''-classic'')">Show MTEX documentation</a>')
  disp('- <a href="matlab:import_wizard(''PoleFigure'')">Import pole figure data</a>')
  disp('- <a href="matlab:import_wizard(''EBSD'')">Import EBSD data</a>')
  disp('- <a href="matlab:import_wizard(''ODF'')">Import ODF data</a>')
  disp(' ');
end
