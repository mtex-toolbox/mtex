function T = reshape(T,varargin)
% reshape for tensors

if nargin == 2, varargin = vec2cell(varargin{1}); end

s = [repcell(3,1,T.rank),varargin];

T.M = reshape(T.M,s{:});
  