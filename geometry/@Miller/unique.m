function [m,ndx,pos] = unique(m,varargin)
% disjoint list of Miller indices
%
% Syntax
%   m = unique(m,<options>)           % 
%   [m,ndx,pos] = unique(m,<options>) %
%
% Input
%  m - @Miller
%
% Output
%  m - @Miller

v = vector3d(symmetrise(m,varargin{:}));

[tmp1,tmp2,pos] = unique(v); %#ok<ASGLU>

[tmp,ndx,pos] = unique(min(reshape(pos,size(v)),[],1)); %#ok<ASGLU>

m = subsref(m,ndx);
