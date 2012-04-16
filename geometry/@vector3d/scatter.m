function varargout = scatter( v, varargin )



[ax,v,varargin] = getAxHandle(v,varargin{:});

projection = plotOptions(ax,v,varargin{:});


[x,y,hemi,p] = project(v,projection);

if numel(varargin) > 0 && isnumeric(varargin{1})
  
  cdata = varargin{1};
  
  if numel(cdata) == numel(v)
    cdata = reshape(cdata,[],1);
  else
    cdata = reshape(cdata,[],3);
  end
  v = reshape(v,[],1);
    
  h = optiondraw(patch('Parent',ax,...
    'vertices',[x(p) y(p)],...
    'faces',1:nnz(p),...
    'facecolor','none',...
    'facevertexcdata',cdata(p),...
    'edgecolor','none',...
    'marker','o',...
    'markersize',2,...
    'markerfacecolor','flat',...
    'markeredgecolor','flat'),varargin{2:end});
  
  if numel(cdata) == numel(v)
    w = cdata;
    opts = {'BL',{'Min:',xnum2str(min(w(:)))},'TL',{'Max:',xnum2str(max(w(:)))}};
  else
    opts = {};
  end
else
  
  h = optiondraw(patch('Parent',ax,...
    'vertices',[x(p) y(p)],...
    'faces',1:nnz(p),...
    'facecolor','none',...
    'edgecolor','none',...
    'marker','o',...
    'markersize',2,...
    'markerfacecolor','b',...
    'markeredgecolor','b'),varargin{:});
  opts = {};
end

plotGrid(ax,projection,varargin{:});

plotAnnotate(ax,opts{:},varargin{:})


if nargout > 0
  varargout{1} = ax;
  varargout{2} = h;
else
    m = 0.025;
    set(ax,'units','normalized','position',[0+m 0+m 1-2*m 1-2*m]);
end

