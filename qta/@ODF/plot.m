function plot(odf,varargin)
% plots odf
%
% this function is only a shortcut to ODF/plotodf

if check_option(varargin,'fibre')
  plotfibre(odf,varargin{:});
else
  plotodf(odf,varargin{:});
end
