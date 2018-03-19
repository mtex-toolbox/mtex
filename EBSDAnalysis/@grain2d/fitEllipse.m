function varargout = fitEllipse(grains,varargin)
% fit ellipses to grains using the method described in Mulchrone&
% Choudhury,2004 (https://doi.org/10.1016/S0191-8141(03)00093-2)
% 
% Syntax
%
%   [omega,a,b] = fitEllipse(grains);
%   plotEllipse(grains.centroid,a,b,omega,'lineColor','r')
%
% Input:
%  grains   - @grain2d
%
% Output:
%  omega    - angle  giving trend of ellipse long axis
%  a        - long axis radius
%  b        - short axis radius
% 
% Option
%  boundary - scale to fit boundary length

[varargout{1:nargout}] = principalComponents(grains,varargin{:});