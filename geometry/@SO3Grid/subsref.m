function o = subsref(S3G,varargin)
% overloads subsref

o = subsref(orientation(S3G),varargin{:});
