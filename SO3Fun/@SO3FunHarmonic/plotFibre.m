function [x,omega] = plotFibre(SO3F,f,varargin)
% plot odf along a fibre
%
% Syntax
%   plotFibre(odf,f);
%
% Input
%  odf - @SO3FunHarmonic
%  f   - @fibre
%
% Options
%  resolution - resolution of each plot
%
% Example
%   odf = SantaFe;
%   f = fibre.gamma(odf.CS,odf.SS)
%   plotFibre(SantaFe,f)
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[x,omega] = plotFibre@SO3Fun(SO3F.subSet(':'),f,varargin{:});

if nargout == 0, clear x omega; end

end