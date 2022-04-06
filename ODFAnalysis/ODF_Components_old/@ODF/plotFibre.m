function [x,omega] = plotFibre(odf,f,varargin)
% plot odf along a fibre
%
% Syntax
%   plotFibre(odf,f);
%
% Input
%  odf - @ODF
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

% get axis
[mtexFig,isNew] = newMtexFigure(varargin{:});

% extract fibre
if isa(f,'fibre')
  [ori,omega] = orientation(f,odf.CS,odf.SS);
elseif isa(varargin{1},'quaternion')
  omega = angle(f(1),f);
  ori = orientation(f,odf.CS,odf.SS);
end

% find loop
delta = angle(ori(2:end),ori(1));
fz = find(delta(:)<1e-2);

% remove values to close together
fz = fz([true;diff(fz)>1]);

if any(fz) && round(numel(delta) / fz(1)) == numel(fz) && ...
    ~check_option(varargin,'comlete')
  ind = 1:find(delta<1e-2,1,'first');
  ori = ori(ind);
  omega = omega(ind);
end

% evaluate the ODF
x = eval(odf,ori,varargin{:});

% plot the fibre
optiondraw(plot(omega./degree,x,'parent',mtexFig.gca),varargin{:});

if isNew
  xlim(mtexFig.gca,[min(omega),max(omega)]./degree);
  ylabel(mtexFig.gca,'Frequency (mrd)')
  xlabel(mtexFig.gca,['misorientation angle (degree) to ' char(ori(1))]);
  drawNow(mtexFig,varargin{:})
end

if nargout == 0, clear x omega; end
