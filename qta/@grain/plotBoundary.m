function varargout = plotBoundary(grains,varargin)
% plot grain boundaries
%
%% Syntax
%  plotBoundary(grains)
%  plotBoundary(grains,'LineSpec',...)
%  plotBoundary(grains,'property',...)
%  plotBoundary(grains,'property',@rotation)
%  plotBoundary(grains,'property','colorcoding',...)
%
%% Options
%  property       - phase, angle, @rotation, @orientation
%  noBG           - omit plotting boundary when property is set
%
%% See also
% grain/plot grain/plotgrains grain/misorientation

% default plot options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

property = lower(get_option(varargin,'property',[]));

newMTEXplot;
if ispolygon(grains), selector(gcf);end

%%

[phase uphase] = get(grains,'phase');

p = polytope( grains );

if ~check_option(varargin,'noBG') && isempty(property)
  [h,po] = plot(p,'color',[0.8 0.8 0.8],'nofix',varargin{:});
else
  h = [];
  po = [];
end

%% colorize by phase
if strcmpi(property,'phase')
  
  pair = pairs(grains);
  
  % remove subgrainboundaries
  pair = pair(~equal(pair,2),:);  
  
  if ~isempty(pair)
    
    % make unique and sorted
    pair = unique(sort(pair,2),'rows');
    
    % number of phases
    np = length(uphase);
    
    % all possible neighborhouds
    [i j] = find(triu(ones(np)));
    
    % enumerate phase / phase pairs
    code = full(sparse(i,j,1:length(i)));
    code = code + triu(code,1)';
    
    % compute the phases of the pairs
    d = phase(pair);
    % and remove all pairs with same phase (why?)
    %ndx = diff(d,[],2) == 0; 
    %pair(ndx,:) = [];
    %d(ndx,:) = [];
    
    % compute colors
    c(uphase) = 1:length(uphase);
    d = c(d);
    
    pair(:,3) = code(sub2ind(size(code),d(:,1),d(:,2)));
    
    %[h(end+1),po(end+1)] = plot(p, 'pair', pair, varargin{:} ); % does not
    % work
    h(end+1) = plot(p, 'pair', pair, varargin{:} );
  end
  
elseif ~isempty(property)
  
  CS = get(grains,'CS');
  
  for ph=uphase(:).'
    %neighboured grains per phase
    ndx = phase == ph;
    grains_phase = grains(ndx);
    
    pair = pairs(grains_phase);
    pair(pair(:,1) == pair(:,2),:) = []; % self reference
    
    if ~isempty(pair)
      
      pair = unique(sort(pair,2),'rows');
      
      % boundary angle
      o = get(grains_phase,'orientation');
      
      om = o(pair(:,1)) .\ o(pair(:,2));
      
      if isa(property,'quaternion')
        
        epsilon = get_option(varargin,'delta',5*degree,'double');
        
        ind = any(find(om,property,epsilon),2);
        
        pair = pair(ind,:);
        
      elseif isa(property,'vector3d')
        
        epsilon = get_option(varargin,'delta',5*degree,'double');
        
        ind = any(reshape(angle(symmetrise(om)*property,property)<epsilon,[],numel(om)),1);
        
        pair = pair(ind,:);
        
      elseif isnumeric(property)
       
        pair(:,3:3+size(property,2)-1) = property;        
        
      elseif ~check_option(varargin,'colorcoding')
        
        d = angle( om )./degree;
        pair(:,3) = d;
        
      else
        
        cc = get_option(varargin,'colorcoding');
        
        d = orientation2color(om,cc,varargin{:});
        pair(:,3:5) = d;
        
      end
      [hn,pn] = plot(p(ndx), 'pair', pair,'nofix', varargin{:} );
      
      h = [h hn];
      po = [po pn];
      
    end
    
  end
  
else
  
  optiondraw(h,varargin{:});
  
end

if ispolygon(grains)
  fixMTEXplot
  set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});
end

if ispolygon(grains)
  selector(gcf,grains,p,h);
end

if check_option(varargin,'colorcoding');
  setappdata(gcf,'CS',CS);
  setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d'));
  setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
  setappdata(gcf,'colorcoding',cc);
  setappdata(gcf,'options',extract_option(varargin,'antipodal'));
end

if nargout > 0
  varargout{1} = h;
end

if nargout > 1
  varargout{2} = po;
end


