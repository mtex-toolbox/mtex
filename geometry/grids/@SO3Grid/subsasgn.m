function S3G = subsasgn(S3G,s,b)
% overloads subsasgn

if isempty(b) || isa(b,'quaternion')
  S3G = subsasgn@orientation(orientation(S3G),s,b);
else
  S3G = subsasgn@orientation(S3G,s,b);
end