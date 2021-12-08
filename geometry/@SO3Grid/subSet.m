function ori = subSet(S3G,varargin)
% indexing of rotation
%
% Syntax
%   ori = subSet(SO3G,ind) % 
%

ori = subSet@orientation(orientation(S3G),varargin{:});
