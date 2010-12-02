function savefigure(fname,varargin)
% save figure as grafik file
%
%% Description
% This function is supposed to produce cropped, publication ready image
% files from your plots. The format of the file is determined by the
% extension of the filename. 
%
%% Syntax
% savefigure(fname,<options>)
%
%% Input
%  filename - string
%  

if nargin == 0, 
  [name,pathstr] = uiputfile({'*.pdf;*.eps;*.ill','Vector Image File'; ...
    '*.jpg;*.tif;*.png;*.gif;*.bmp;*pgm;*.ppm','Bitmap Image Files';...
    '*.*','All Files' },'Save Image','newfile.pdf');
  if isequal(name,0) || isequal(pathstr,0), return;end
  fname = [pathstr,name];
end

[pathstr, name, ext] = fileparts(fname);

ounits = get(gcf,'Units');
set(gcf,'PaperPositionMode','auto');
set(gcf,'Units','pixels');
pos = get(gcf,'Position');
si = get(gcf,'UserData');
	
if (length(si) == 2) && isempty(findall(gcf,'tag','Colorbar'))
  pos([3,4]) = si;
	set(gcf,'Position',pos);
%	annotation('rectangle',[0 0 1 1]);
end

set(gcf,'Units','centimeters');
pos = get(gcf,'PaperPosition');
set(gcf,'PaperUnits','centimeters','PaperSize',[pos(3),pos(4)]);
set(gcf,'Units',ounits);

switch lower(ext(2:end))

case {'eps','ps'}
  flags = {'-depsc'};  
  %set(gcf,'renderer','painters');
case 'ill'
  flags = {'-dill'};  
  %set(gcf,'renderer','painters');  
case {'pdf'}
  flags = {'-dpdf'};
  %set(gcf,'renderer','painters');  
case {'jpg','jpeg'}
  flags = {'-r600','-djpeg'};  
  set(gcf,'renderer','zbuffer');
case {'tiff'}
  flags = {'-r600','-dtiff'};
case {'png'}
  flags = {'-r600','-dpng'};
case {'bmp'}
  flags = {'-r600','-dbmp'};
otherwise
  saveas(gcf,fname);
  return
end

print(fname,flags{:},varargin{:});
