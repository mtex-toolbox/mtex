function annotate(varargin)
% plots to all axes of the current figure
%
%% Syntax
%
%  annotate([xvector,yvector,zvector])
%  annotate(Miller(1,1,1,cs),'all')
%
%% Description
% The function *annotate* plots annotations, e.g. specimen or crystal
% directions to all subfigures of the current figure. You can pass to
% *annotate* all the options you would normaly would like to pass to the
% ordinary plot command.
%
%% See also
% Miller/plot vector3d/plot

%% get axes 

if nargin == 0 || isempty(varargin{1}), return; end

oax = get(gcf,'currentAxes');

if all(ishandle(varargin{1}))
  ax = varargin{1};
  varargin = varargin{:};
elseif isappdata(gcf,'axes')
  ax = get_option(varargin,'axes', getappdata(gcf,'axes'));
else
  ax = findobj(gcf,'type','axes');
end


%% get obj and some data 
obj = varargin{1};
varargin(1) = [];

ss = getappdata(gcf,'SS');
cs = getappdata(gcf,'CS');
o = getappdata(gcf,'options');
if ~isempty(o), varargin = {o{:},varargin{:}};end


%% special case quaternion
if isa(obj,'quaternion')
  
  if length(obj) > 1 % split if more then one orientation
    for i = 1:length(obj), annotate(obj(i),varargin{:});end    
    return;
  end
  
  if isappdata(gcf,'sections') 
    % precalculate projection if plotted to sections
    S2G = project2ODFsection(orientation(obj,cs,ss),...
      getappdata(gcf,'SectionType'),getappdata(gcf,'sections'),varargin{:});
  end  
end


%% plot into all axes
for i = 1:length(ax)
  set(gcf,'currentAxes',ax(i));
  
  washold = ishold;
  hold all;
    
  switch get(gcf,'tag')
  
%% pole figure plot
    case 'pdf' 
    
      h = getappdata(gca,'h');
        
      if isa(obj,'quaternion')
      
        plot((quaternion(obj)*ss)*symmetrise(h,varargin{:}),'MarkerEdgeColor','w',varargin{:});
        
      elseif isa(obj,'vector3d')
      
        plot(obj,'Marker','s','MarkerFaceColor','k',...
          'MarkerEdgeColor','w','Marker','s',varargin{:});
      
      else
        error('Only orientations and specimen directions can be anotated to pole figure plots');
      end
    
  %% inverse pole figure plot    
    case {'ipdf','hkl'}
        
      r = getappdata(gca,'r');
      if isempty(r), r = getappdata(gcf,'r');end
    
      if isa(obj,'quaternion')
        sr = inverse(obj)*symmetrise(r./norm(r),ss,varargin{:});
        plot(cs*sr(:).','MarkerEdgeColor','w',varargin{:});
      elseif isa(obj,'Miller')
      
        obj = set(obj,'CS',cs);
        plot(obj,'all','MarkerEdgeColor','w','Marker','s',varargin{:});
      
      else
        error('Only orientations and Miller indece can be anotated to inverse pole figure plots');
      end
    
  %% ODF sections plot
    case 'odf'
   
      if isa(obj,'quaternion')
        plot(S2G{i},varargin{:});
      else
        error('Only orientations can be anotated to ODF section plots');
      end
    
  %% EBSD 3d scatter plot
    case  'ebsd_scatter'
   
      if isa(obj,'quaternion')
        S3G = SO3Grid(obj,cs,ss);
        plot(S3G,'center',getappdata(gca,'center'),varargin{:});
      else
        error('Only orientations can be anotated to EBSD scatter plots');
      end
    
  
    otherwise % not supported -> skip        
    
  end
  if ~washold, hold off;end
end

set(gcf,'currentAxes',oax,'nextplot','replace');
