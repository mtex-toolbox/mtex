function [x,omega] = plotFibre(odf,varargin)
% plot odf along a fibre
%
% Syntax
%  plotFibre(odf,h,r);
%  plotFibre(odf,f);
%
% Input
%  odf - @ODF
%  f   - @fibre
%  h   - @Miller crystal directions
%  r   - @vector3d specimen direction
%
% Options
%  resolution - resolution of each plot
%  center     - for radially symmetric plot
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
if isa(varargin{1},'vector3d')
  varargin{1} = odf.CS.ensureCS(varargin{1});
  omega = linspace(0,2*pi,501);
  center = get_option(varargin,'CENTER',hr2quat(varargin{1},varargin{2}),{'quaternion','rotation','orientation'});
  f = orientation(axis2quat(varargin{2},omega) .* center,odf.CS,odf.SS);
elseif  isa(varargin{1},'fibre')
  [f,omega] = orientation(varargin{1},odf.CS,odf.SS);
elseif isa(varargin{1},'quaternion')
  omega = angle(varargin{1}(1),varargin{1});
  f = orientation(varargin{1},odf.CS,odf.SS);
end

% find loop
delta = angle(f(2:end),f(1));
fz = find(delta(:)<1e-2);

% remove values to close together
fz = fz([true;diff(fz)>1]);

if any(fz) && round(numel(delta) / fz(1)) == numel(fz) && ...
    ~check_option(varargin,'comlete')
  ind = 1:find(delta<1e-2,1,'first');
  f = f(ind);
  omega = omega(ind);
end

% evaluate the ODF
x = eval(odf,f,varargin{:});%#ok<EVLC>

% plot the fibre
optiondraw(plot(omega./degree,x,'parent',mtexFig.gca),varargin{:});

if isNew
  xlim(mtexFig.gca,[min(omega),max(omega)]./degree);
  ylabel(mtexFig.gca,'Frequency (mrd)')
  xlabel(mtexFig.gca,['misorientation angle (degree) to ' char(f(1))]);
  drawNow(mtexFig,varargin{:})
end

if nargout == 0, clear x omega; end
