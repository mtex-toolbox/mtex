function h = plot(obj,varargin)
% two dimensional plot of embeddings
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

scatter(d(:,1),d(:,2),varargin{:})



