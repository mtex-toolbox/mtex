function varargout = line( v, varargin )




[h p] = scatter(reshape(v,[],1),varargin{:});

p = optiondraw(p,'edgecolor','k');

if nargout>0
  varargout{1} = h;
  varargout{2} = p;
end
