function S3G = subsasgn(S3G,s,b)
% overloads subsasgn

try
  % subindexing SO3Grid is orientation!!
  S3G = subsasgn@orientation(orientation(S3G),s,b);
catch %#ok<CTCH>
  S3G = builtin('subsasgn',S3G,s,b);
end