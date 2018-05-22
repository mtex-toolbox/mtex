function varargout = plot(f,varargin)
% plot a fibre

o = f.orientation(varargin{:});

if isempty(o), varargout = cell(1,nargout); return; end

if isa(o,'orientation')

  if check_option(varargin,'project2FundamentalRegion')
  
    o = o.project2FundamentalRegion;
      
  elseif check_option(varargin,'restrict2FundamentalRegion')
  
    oR = fundamentalRegion(f.CS,f.SS);
    o(~oR.checkInside(o))=nan;
  
  end
end

[varargout{1:nargout}] = line(o,varargin{:});

end