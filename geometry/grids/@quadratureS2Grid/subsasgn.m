function S2G = subsasgn(S2G,s,b)
% overloads subsasgn

try
  % subindexing S2Grid is vector3d!!
  S2G = subsasgn@orientation(vector3d(S2G),s,b);
catch %#ok<CTCH>
  S2G = builtin('subsasgn',S2G,s,b);
end