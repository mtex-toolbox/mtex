function plotgrains(grains,varargin)
% plot the grain boundaries
%
%% Syntax
%  plotgrains(grains)
%  plotgrains(grains,LineSpec,...)
%  plotgrains(grains,'property',PropertyValue,...)
%  plotgrains(grains,'property','orientation',...)
%
%% Input
%  grains - @grain
%
%% Options
%  NOHOLES  -  plot grains without holes
%
%% See also
% grain/plot grain/plotellipse grain/plotsubfractions

% restrict phase if necassary
grains = copy(grains,varargin{:});

% get property to plot
property = get_option(varargin,'property','orientation');

%% plot property phase 
if strcmp(property,'phase') && ~check_option(varargin,'FaceColor')
  
  % colormap for phase plot
  cmap = get_mtex_option('PhaseColorMap');
  
  % get all phases
  grainPhases = get(grains,'phase');
  [phases,ind] = unique(grainPhases);

  varargin = set_option(varargin,'property','none');
  % plot all phases separately
  washold = ishold;
  hold all;
  for i = 1:length(phases)    
    faceColor = cmap(1+mod(phases(i)-1,length(cmap)),:);
    plotgrains(grains(grainPhases == phases(i)),varargin{:},'FaceColor',faceColor);
  end
  if ~washold, hold off;end
  
  % add a legend
  [minerals{1:length(phases)}] = get(grains(ind),'mineral');    
  legend(minerals);
  
  return
end



% maybe grains should be plotted together with its EBSD data
if nargin>1 && isa(varargin{1},'EBSD')
  ebsd = varargin{1};
  varargin = varargin(2:end);
elseif nargin>1 && isa(grains,'EBSD') && isa(varargin{1},'grain')
  ebsd = grains;
  grains = varargin{1};
  varargin = varargin(2:end);
end

% set up figure
newMTEXplot;
% if ispolygon(grains), selector(gcf);end

%% what to plot
if ~isempty(property)
  
  % orientation to color
  if strcmpi(property,'orientation')
    
    cc = lower(get_option(varargin,'colorcoding','ipdf'));
    
    [phase,uphase]= get(grains,'phase');    
    CS = cell(size(uphase));
    
    d = zeros(numel(grains),3);
    for k=1:numel(uphase)
       sel = phase == uphase(k);
       o = get(grains(sel),property);
       CS{k} = get(o,'CS');
       
       c = orientation2color(o,cc,varargin{:});
       d(sel,:) = reshape(c,[],3);
    end
    
    setappdata(gcf,'CS',CS);
    setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d')); 
    setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
    setappdata(gcf,'colorcoding',cc);
    setappdata(gcf,'options',extract_option(varargin,'antipodal'));
    
  elseif strcmpi(property,'none')
        
    d = [];
  % property to color
  elseif any(strcmpi(property, fields(grains))) ||...
     any(strcmpi(property,fields(grains(1).properties)))
  
    d = reshape(get(grains,property),[],1);
    
    if strcmpi(property,'phase')
      colormap(hsv(max(d)+1));
    end
    
  elseif  isnumeric(property) && length(grains) == length(property) || islogical(property)
    
    d = reshape(property,[],1);
    
  end
   
  % extract the polytopes
  p = polytope(grains);
  
  % plot them
  if ~isempty(d)
    h = plot( p ,'fill',d,varargin{:});
  else
    h = plot( p ,varargin{:});
  end
  
  if ispolygon(grains)
%     selector(gcf,grains,p,h);
  end
elseif exist('ebsd','var') 
  
  if check_option(varargin,'misorientation')
    
    plotspatial(misorientation(grains,ebsd),varargin{:});
    return
  end
  
else
  
  p = polygon(grains);
  h = plot( p , varargin{:});


  if ispolygon(grains)
    selector(gcf,grains,p,h);
  end  
end

