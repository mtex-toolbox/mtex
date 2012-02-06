function varargout = get(obj,vname,varargin)
% get object variable

 
switch lower(vname)
  case 'cs'
    varargout{1} = obj.CS;
  case 'ss'
    varargout{1} = obj.SS;
  case 'mineral'
    varargout{1} = get(obj.CS,'mineral');
  case 'euler'
    [varargout{1:nargout}] = Euler(obj,varargin{:});
  otherwise
    try
      varargout{1} = get(obj.rotation,vname,varargin{:});
    catch %#ok<CTCH>
      error(['There is no ''' vname ''' property in the ''' class(obj) ''' object'])
    end
end


