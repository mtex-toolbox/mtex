function saveFigure(fname,varargin)
% save figure as grafik file
%
% Description
% This function is supposed to produce cropped, publication ready image
% files from your plots. The format of the file is determined by the
% extension of the filename. 
%
% Syntax
%   savefigure(fname,<options>)
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

%if ~isempty(gcm), drawNow(gcm,'autoPosition');end

setPaperSize;

% for recent Matlab versions saveas should be fine
if ~verLessThan('matlab','8.4'), saveas(gcf,fname); return; end

% seperate extension
[~, ~, ext] = fileparts(fname);

% try to switch to painters mode for vector formats
% by converting RGB graphics to indexed graphics
if any(strcmpi(ext,{'.eps','.pdf'})) && ~strcmpi(get(gcf,'renderer'),'painters') ...
    && isRGB
  
  try
    convertFigureRGB2ind;
    set(gcf,'renderer','painters');
  catch
    warning('MTEX:export','Unable to switch to painter''s mode. You may need to export to png or jpg');
  end
  
end

% for bitmap formats try to use export fig
if all(~strcmpi(ext,{'.eps','.pdf'}))
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

% determine flags
switch lower(ext(2:end))
  
  case {'eps','ps'}
    flags = {'-depsc'};
  case 'ill'
    flags = {'-dill'};
case {'pdf'}
  flags = {'-dpdf'};
case {'jpg','jpeg'}
  flags = {'-r600','-djpeg'};
  set(gcf,'renderer','zbuffer');
  case {'tiff'}
  flags = {'-r500','-dtiff'};
  case {'png'}
    flags = {'-r500','-dpng'};
  case {'bmp'}
    flags = {'-r500','-dbmp'};
otherwise
  saveas(gcf,fname);
  return
end

printOptions = delete_option(varargin,{'crop','pdf'});
print(fname,flags{:},printOptions{:});

if check_option(varargin,'pdf')
  unix(['epstopdf' ' ' fname]);
  fname = strrep(fname,'eps','pdf');
  unix(['pdfcrop' ' ' fname ' ' fname]);
end

if check_option(varargin,'crop')
  
  unix(['pdfcrop' ' ' fname ' ' fname]);
  
end

end

% ------------------------------------------------------------------
function out = isRGB

out = false;

ax = findall(gcf,'type','axes');
childs = findobj(ax,'-property','CData');
    
if isempty(childs), return;end
    
CData = ensurecell(get(childs,'CData'));
    
out = any(cellfun(@(x) size(x,3)==3,CData));

end

%
function convertAxisLabel2text

ax = findall(gcf,'type','axes');

for iax = 1:numel(ax)
  
  xLabel = get(ax(iax),'XTickLabel');
  x = get(ax(iax),'XTick');
  if ~isempty(xLabel) && ~isempty(x)
    y = ylim(ax(iax));
    text(ax(iax),x,repmat(y(1),size(x)),...
      'FontName',get(ax(iax),'FontName'),...
      'FontAngle',get(ax(iax),'FontAngle'),...
      'FontWeight',get(ax(iax),'FontWeight'),...
      'interpreter','tex');
    set(ax(iax),'XTickLabel',[]);
  end    
end
  
end

function setPaperSize
% resize figure to look good

ounits = get(gcf,'Units');
set(gcf,'PaperPositionMode','auto');
set(gcf,'Units','centimeters');
pos = get(gcf,'PaperPosition');
set(gcf,'PaperUnits','centimeters','PaperSize',[pos(3),pos(4)]);
set(gcf,'Units',ounits);


end
