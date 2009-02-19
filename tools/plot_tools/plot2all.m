function plot2all(varargin)
% plots to all axes of the current figure
%
%% Syntax
%
%  plot2all([xvector,yvector,zvector])
%  plot2all(Miller(1,1,1,cs),'all')
%
%% Description
% The function *plot2all* plots annotations, e.g. specimen or crystal
% directions to all subfigures of the current figure. You can pass to
% *plot2all* all the options you would normaly would like to pass to the
% ordinary plot command.
%
%% See also
% Miller/plot vector3d/plot

%% get data
oax = get(gcf,'currentAxes');

if isappdata(gcf,'axes')
  ax = get_option(varargin,'axes', ...
    getappdata(gcf,'axes'));
else
  ax = findobj(gcf,'tag','ebsd_raster');
end

m = getappdata(gcf,'Miller');
r = getappdata(gcf,'vector3d');
sec = getappdata(gcf,'sections');
if isappdata(gcf,'SS')
  ss = getappdata(gcf,'SS');
  cs = getappdata(gcf,'CS');
else
  ss = symmetry; cs = symmetry;
end

%% quaternion plot - split needed?
if isa(varargin{1},'quaternion')
  q = varargin{1};
  if length(q) > 1
    for i = 1:length(q)
      plot2all(q(i),varargin{2:end});
    end
    return;
  elseif isappdata(gcf,'sections')
    S2G = project2ODFsection(SO3Grid(ss*varargin{1}*cs,cs,ss),...
      getappdata(gcf,'SectionType'),sec,varargin{:});
  end
end

%% plot into all axes
for i = 1:length(ax)
  set(gcf,'currentAxes',ax(i));
  
  washold = ishold;
  hold all;
  
  % function handle
  if isa(varargin{1},'function_handle') 
    plot(varargin{1}(i),varargin{2:end});
    
  % cell  
  elseif isa(varargin{1},'cell')
    plot(varargin{1}{i},varargin{2:end});
    
  % quaternion pole figure plot
  elseif isa(varargin{1},'quaternion') && isappdata(gcf,'Miller')
        
    plot(ss*q*symeq(m(i)),'MarkerEdgeColor','w',varargin{2:end});
    
  % quaternion inverse pole figure plot    
  elseif isa(varargin{1},'quaternion') && isappdata(gcf,'vector3d')
        
    sr = inverse(q)*(ss*(r(i)./norm(r(i))));
    plot(cs*sr(:).','MarkerEdgeColor','w',varargin{2:end});
    
  % quaternion ODF plot
  elseif  isa(varargin{1},'quaternion') && isappdata(gcf,'sections')
   
    plot(S2G(i),varargin{2:end});
    
  elseif  isa(varargin{1},'quaternion') && isappdata(gcf,'center')
   
    S3G = SO3Grid(varargin{1},cs,ss);
    plot(S3G,'center',getappdata(gcf,'center'),varargin{2:end});
    
  % vector3d  
  elseif isa(varargin{1},'vector3d')
    plot(varargin{1},'Marker','s','MarkerFaceColor','k',...
      'MarkerEdgeColor','w','Marker','s',varargin{2:end});
  else
    plot(varargin{:});
  end
  if ~washold, hold off;end
end

set(gcf,'currentAxes',oax,'nextplot','replace');
