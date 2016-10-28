function plot(odf,varargin)
% plots odf
%
% Syntax
%
%   % plot the odf along the alpha fibre
%   f = fibre.alpha(odf.CS)
%   plot(odf,f)
%
%   % plot the odf as phi2 sections
%   oS = phi2Sections(odf.CS)
%   plot(odf,oS)
%
% this function is only a shortcut to plotSection, plot3d and plotFibre

if nargin > 1 && isa(varargin{1},'fibre')
  plotFibre(odf,varargin{:});
elseif check_option(varargin,'3d')
  plot3d(odf,varargin{:});
else
  plotSection(odf,varargin{:});
end
