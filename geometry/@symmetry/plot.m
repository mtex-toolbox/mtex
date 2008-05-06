function plot(s,varargin)
% plot symmetry

m = [Miller(1,0,0,s),Miller(0,0,1,s),Miller(0,1,1,s)];


plot(m,'All',varargin{:},'north','south');
