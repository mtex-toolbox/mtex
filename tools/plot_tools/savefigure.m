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

%%

cmaplength = 1024;
globmap = [];


% try to switch to painters mode
if any(strcmpi(ext,{'.eps','.pdf'})) && ~strcmpi(get(gcf,'renderer'),'painters')

  ax = findall(gcf,'type','axes');
  for iax = 1:numel(ax)
   
    childs = findobj(ax(iax),'-property','CData');
    
    if isempty(childs), continue;end
    
    CData = get(childs,'CData');
    
    CData = ensurecell(CData);
    
    % ensure all data have the same size
    dim2 = cellfun(@(x) size(x,3),CData);

    if numel(unique(dim2)) > 1
      for k = 1:numel(CData)
        CData{k} = repmat(CData{k},[1,1,max(dim2)/dim2(k)]);
      end
    end
    
    %
    combined = cat(1,CData{:});
    
    if size(combined,3) == 1, continue;end
    
    % convert to index data
    [data, map] = rgb2ind(combined, cmaplength);
    
    % shift data to fit globmap
    data = data + (iax-1)*cmaplength;
    globmap = [globmap;map]; %#ok<AGROW>

    pos = 1;
    for ind = 1:numel(CData)
  
      s = size(CData{ind});
      set(childs(ind),'CData',...
        reshape(double(data(pos:pos+prod(s(1:2))-1)),s(1:2)));
      pos = pos + prod(s(1:2));
    end    
  end  
  
  %set new colormap
  set(gcf,'colormap',globmap);
  setcolorrange('equal');
  set(gcf,'renderer','painters')
end

 
%%

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
