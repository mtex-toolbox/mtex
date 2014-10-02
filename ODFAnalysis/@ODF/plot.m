function plot(odf,varargin)
% plots odf
%
% this function is only a shortcut to ODF/plotODF

if check_option(varargin,'fibre')
  plotFibre(odf,varargin{:});
else
  plotODF(odf,varargin{:});
end
