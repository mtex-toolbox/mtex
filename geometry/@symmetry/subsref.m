function rot = subsref(sym,varargin)
% overloads subsref

rot = subsref(rotation(sym),varargin{:});
