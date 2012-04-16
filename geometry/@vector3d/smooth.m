function varargout = smooth( v, varargin )
%SMOOTH Summary of this function goes here
%   Detailed explanation goes here




[ax,v,varargin] = getAxHandle(v,varargin{:});


projection = plotOptions(ax,v,varargin{:});


hfig = get(ax,'parent');
set(hfig,'color',[1 1 1]);

if ~isempty(varargin) && isnumeric(varargin{1})
  weight = varargin{1};
else
  weight = ones(size(v));
end

if isa(v,'S2Grid') && check_option(v.options,{'plot'})
  w = weight;
else
  hemi = ensurecell(projection.hemisphere);
  out = S2Grid('plot',hemi{:});
  
  res = get(S2Grid(v),'resolution');
  
  w = kernelDensityEstimation(v(:),out,'weights',weight(:),'halfwidth',res,varargin{:});
  v = out;
  
  if check_option(varargin,'scaled')
    mi = min(w(:)); mmi = min(weight(:));
    ma = max(w(:)); mma = max(weight(:));
    w = (w-mi)./(ma-mi)*(mma-mmi)+mmi;
  end
  %     w = w.*mean(weight(:));
  w = reshape(w,size(v));
end

p = projection;
l = get_option(varargin,'contours',50);
h = [];

if strcmpi(p.type,'plain')
  
  [xu,yu] = project(v,p);
  
  w = reshape(w,size(xu));
  [CM,h(end+1)] = contourf(ax,xu,yu,w,l);
  
else
  
  theta = polar(v);
  % return
  hold(ax,'on')
  if check_option(ensurecell(projection.hemisphere),{'north','both','upper','antipodal'})
    indu = theta <= pi/2+0.001;
    upper = submatrix(v,indu);
    data_upper = reshape(submatrix(w,indu),size(upper));
    if all(size(data_upper)>1)
      p.hemisphere = 'north';
      [xu,yu] = project(upper,p);
      [CM,h(end+1)] = contourf(ax,xu,yu,data_upper,l);
    end
  end
  
  if check_option(ensurecell(projection.hemisphere),{'south','both','lower'})
    indl = theta >= pi/2-0.001;
    lower = submatrix(v,indl);
    data_lower = reshape(submatrix(w,indl),size(lower));
    if all(size(data_lower)>1)
      p.hemisphere = 'south';
      [xl,yl] = project(lower,p);
      [CM,h(end+1)] = contourf(ax,xl,yl,data_lower,l);
    end
  end
  hold(ax,'off')
end

optiondraw(h,'LineStyle','none',varargin{:});
optiondraw(h,'Fill','on',varargin{:});

plotGrid(ax,projection,varargin{:});


opts = {'BL',{'Min:',xnum2str(min(w(:)))},'TL',{'Max:',xnum2str(max(w(:)))}};


plotAnnotate(ax,opts{:},varargin{:})

if nargout > 0
  varargout{1} = h;
end

