function h = plot(g3B,varargin)

% create a new plot
%mtexFig = newMtexFigure('datacursormode',{@tooltip,grains},varargin{:});
mtexFig = newMtexFigure(varargin{:});
[mP,isNew] = newMapPlot('scanUnit','um','parent',mtexFig.gca,...
  g3B.allV.plottingConvention, varargin{:});

if isempty(g3B)
  if nargout==1, h = [];end
  return;
end

V = g3B.allV;
F = g3B.F;

if nargin>1 && isnumeric(varargin{1}) % color by property

  faceColor = varargin{1};
  
elseif check_option(varargin,'FaceColor')

  faceColor = str2rgb(get_option(varargin, 'FaceColor'));
  varargin = delete_option(varargin, 'FaceColor',1);

end

pObj.Vertices = V.xyz;
pObj.parent = mP.ax;

if size(faceColor,1) == size(F,1)
  pObj.FaceColor = 'flat';
  pObj.FaceVertexCData = faceColor;
else
  pObj.FaceColor = faceColor;
end

% extract faces
if iscell(F)
  pObj.Faces = nan(length(F),max(cellfun(@numel,F)));
  for iF = 1:numel(F)
    pObj.Faces(iF,1:length(F{iF})) = F{iF};
  end
else
  pObj.Faces = F;
end

% do plot
h = optiondraw(patch(pObj),varargin{:});

pause(0.1)

fcw

if nargout==0, clear h; end

end