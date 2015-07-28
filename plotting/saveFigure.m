function saveFigure(fname,varargin)
% save figure as graphics file
%
% Description
% This function is supposed to produce cropped, publication ready image
% files from your plots. The format of the file is determined by the
% extension of the filename. 
%
% Syntax
%   saveFigure(fname)
%
% Input
%  filename - string
%  

% no file name given select from dialog
if nargin == 0, 
  [name,pathstr] = uiputfile({'*.pdf;*.eps;*.ill','Vector Image File'; ...
    '*.jpg;*.tif;*.png;*.gif;*.bmp;*pgm;*.ppm','Bitmap Image Files';...
    '*.*','All Files' },'Save Image','newfile.pdf');
  if isequal(name,0) || isequal(pathstr,0), return;end
  fname = [pathstr,name];
end

try
  oldColor = get(gcf,'color');
  set(gcf,'color','w');
  export_fig(gcf,fname,'-m1.5');
  %export_fig(gcf,fname);
  if exist(fname,'file'),
    set(gcf,'color',oldColor);
    return;
  end
catch
end

set(gcf,'color',oldColor);

end
