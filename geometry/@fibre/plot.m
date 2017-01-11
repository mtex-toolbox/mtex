function h = plot(f,varargin)

o = f.orientation(varargin{:});

if isempty(o), h = []; return; end

if isa(o,'orientation')

  if check_option(varargin,'project2FundamentalRegion')
  
    o = o.project2FundamentalRegion;
      
  elseif check_option(varargin,'restrict2FundamentalRegion')
  
    oR = fundamentalRegion(f.CS,f.SS);
    o(~oR.checkInside(o))=nan;
  
  end
end

h = line(o,varargin{:});

if nargout == 0, clear h; end

end