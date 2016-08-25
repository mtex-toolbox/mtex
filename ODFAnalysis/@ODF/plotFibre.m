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

%
if isa(varargin{1},'vector3d')
  varargin{1} = odf.CS.ensureCS(varargin{1});
  omega = linspace(-pi,pi,501);
  center = get_option(varargin,'CENTER',hr2quat(varargin{1},varargin{2}),{'quaternion','rotation','orientation'});
  fibre = axis2quat(varargin{2},omega) .* center;
elseif isa(varargin{1},'quaternion') || isa(varargin{1},'fibre')
  fibre = varargin{1};
end

%
[fibre,omega] = orientation(fibre,odf.CS,odf.SS);

% find loop
delta = angle(fibre(2:end),fibre(1));
fz = find(delta(:)<1e-2);

% remove values to close together
fz = fz([true;diff(fz)>1]);

if any(fz) && round(numel(delta) / fz(1)) == numel(fz) && ...
    ~check_option(varargin,'comlete')
  fibre = fibre(1:find(delta<1e-2,1,'first'));
end

% determine some nice orientations along the fibre
% this is quit difficult
e = Euler(fibre) ./ degree;

err = sum(round(100*abs(round(e./5) - e./5)),2);

ind = false(size(err));

while nnz(ind) < 5
  
  % new candidates
  ind2 = min(err) == err;
  err(ind2) = inf;
  
  % compute the distance to the previous ticks
  if any(ind)
    d = arrayfun(@(x) min(abs(x-find(ind))),1:numel(ind));  
    
    % take only those candidates that are sufficent far away
    ind2 = ind2 & d.' > max(d) / 1.75;
  end
  
  ind = ind | ind2;
end

x = eval(odf,fibre,varargin{:});%#ok<EVLC>

optiondraw(plot(omega./degree,x,'parent',mtexFig.gca),varargin{:});

if isNew
  xlim(mtexFig.gca,[min(omega),max(omega)]./degree);
  ylabel(mtexFig.gca,'Frequency (mrd)')
  xlabel(mtexFig.gca,['misorientation angle (degree) to ' char(fibre(1))]);
  label = arrayfun(@(i) char(fibre(i),'nodegree'),find(ind),'uniformoutput',false);
  try
    xticklabel_rotate(find(ind),90,label);
  catch
  end
  drawNow(mtexFig,varargin{:})
end

if nargout == 0, clear x omega; end

