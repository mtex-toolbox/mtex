function plotAxisDistribution(ebsd1,varargin)
% plot uncorrelated axis distribution
%
% Input
%  ebsd   - @EBSD
%  grains - @grainSet
%
% Options
%  resolution - resolution of the plots
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%  complete  - plot entire (hemi)--sphere
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure(varargin{:});

% get phases
if nargin > 1 && isa(varargin{1},'EBSD')
  ebsd2 = varargin{1};
  varargin{1} = [];
else
  ebsd2 = ebsd1;
end

% only consider indexed data
ebsd1 = subSet(ebsd1,ebsd1.isIndexed);
ebsd2 = subSet(ebsd2,ebsd2.isIndexed);

% split according to phases
phases1 = ebsd1.phase;
ph1 = unique(phases1);

phases2 = ebsd2.phase;
ph2 = unique(phases2);

[ph, phpos] = unique([ph1,ph2],'first');
for j = 1:numel(ph)
  if ismember(ph(j),ph1)
    ebsd = subSet(ebsd1,phases1 == ph(j));
  else
    ebsd = subSet(ebsd2,phases2 == ph(j));
  end
  if check_option(varargin,{'ODF','MDF'})
    objSplit{phpos(j)} = calcFourierODF(ebsd.orientations,'halfwidth',10*degree,varargin{:}); %#ok<AGROW>
  else
    objSplit{phpos(j)} = ebsd; %#ok<AGROW>
  end
end

% all combinations of phases
[ph1,ph2] = meshgrid(phpos(ismember(ph,ph1)),phpos(ismember(ph,ph2)));
ph1 = ph1(tril(ones(size(ph1)))>0);
ph2 = ph2(tril(ones(size(ph2)))>0);

% plot angle distributions
for i = 1:numel(ph1)
  
  if i > 1, mtexFig.nextAxis; end
    
  mori = calcMisorientation(objSplit{ph1(i)},objSplit{ph2(i)},varargin{:});
  plot(mori.axis,'doNotDraw','symmetrised','parent',mtexFig.gca,...
    'FundamentalRegion',varargin{:});
  mtexTitle(mtexFig.gca,[mori.CS.mineral ' - ' mori.SS.mineral])
  
end

if isNew % finalize plot
  set(gcf,'Name','Misorientation Axes Distribution');
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
end

if nargout == 0, clear h; end
