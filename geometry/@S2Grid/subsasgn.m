function S2G = subsasgn(S2G,varargin)
%overloads subsasgn

S2G.vector3d = subsasgn(S2G.vector3d,varargin{:});

S2G = delete_option(S2G,'indexed');
