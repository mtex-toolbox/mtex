function S3G = subsasgn(S3G,s,b)
% overloads subsasgn

S3G = subsasgn@orientation(orientation(S3G),s,b);
