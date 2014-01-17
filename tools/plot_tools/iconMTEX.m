function iconMTEX(hFig)

try
  jframe=get(hFig,'javaframe');
  jIcon=javax.swing.ImageIcon(fullfile(mtex_path,'mtex_icon.gif'));
  jframe.setFigureIcon(jIcon);
catch
end