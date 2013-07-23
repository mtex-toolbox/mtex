function  MTEXdoc(varargin)

if verLessThan('matlab','8.0')
  doc(varargin{:})
else
  doc(varargin{:},'-classic')
end

end

