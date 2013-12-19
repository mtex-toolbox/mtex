function varargout = ismembc (varargin)
  if (nargout == 0)
    ismember (varargin{:});
  else
    varargout = cell (nargout, 1);
    [varargout{:}] = ismember (varargin{:});
  endif
endfunction
