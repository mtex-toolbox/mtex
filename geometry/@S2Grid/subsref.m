function S2G = subsref(S2G,varargin)
%overloads subsref

S2G.vector3d = subsref(S2G.vector3d,varargin{:});
S2G = delete_option(S2G,'indexed');
