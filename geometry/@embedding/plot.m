function h = plot(obj,varargin)
% two dimensional plot of an embedding
%
% Syntax
%   plot(e)
%
%   h = plot(e)
%
% Input
%  e - @embedding
%
% Output
%  h - graphics handle

d = double(obj);

[~,d] = pca(d);

h = scatter(d(:,1),d(:,2),varargin{:});

if nargout == 0, clear h; end



