function [v,x] = max(S1F,varargin)

x = linspace(0,2*pi);
y = S1F.eval(x);
[v,ind] = max(y);

x = x(ind);