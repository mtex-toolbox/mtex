function plotGrains(grains,varargin)
% colorize grains
%
% Input
%  grains  - @Grain3d
% Options
%  property - colorize a grains by given property, variants are:
%
%    * |'phase'| -- make a phase map.
%
%    * |'orientation'| -- colorize a grain after its orientaiton
%
%            plot(grains,'property','orientation',...
%              'colorcoding','ipdf');
%
%  PatchProperty - see documentation of patch objects for manipulating the
%                 apperance, e.g. 'EdgeColor'
% See also
% Grain2d/plotGrains

obj.Vertices = grains.V;
obj.Faces    = grains.F;

obj.EdgeColor = 'none';
obj.FaceColor = 'flat';

% seperate measurements per phase
numberOfPhases = numel(grains.phaseMap);
d = cell(1,numberOfPhases);

isPhase = false(numberOfPhases,1);
for k=1:numberOfPhases
  currentPhase = grains.phase==grains.phaseMap(k);
  isPhase(k)   = any(currentPhase);
  
  if isPhase(k)
    [d{k},property,opts] = calcColorCode(grains,currentPhase,varargin{:});
  end
end

d = vertcat(d{:});


I_FD = grains.I_FDext;
I_DG = grains.I_DG;

[f,g] = find(double(I_FD)*I_DG(:,any(I_DG)));

obj.Faces           = obj.Faces(f,:);
obj.FaceVertexCData = d(g,:);

if check_option(varargin,{'transparent','translucent'}) 
  s = get_option(varargin,{'transparent','translucent'},1,'double');
  d = obj.FaceVertexCData;
  if size(d,2) == 3 % rgb
    obj.FaceVertexAlphaData = s.*(1-min(d,[],2));
  else
    obj.FaceVertexAlphaData = s.*d./max(d);
  end
  obj.AlphaDataMapping = 'none';
  obj.FaceAlpha = 'flat';
end

if isempty(obj.Faces)
  warning('nothing to plot');
else
  h = optiondraw(patch(obj),varargin{:});
  fixMTEXplot;
  optiondraw(h,varargin{:});
    
  % set appdata
  if strncmpi(property,'orientation',11)
    setappdata(gcf,'CS',grains.allCS(isPhase));
    setappdata(gcf,'inversePoleFigureDirection',get_option(opts,'r',xvector));
    setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
    setappdata(gcf,'colorcoding',property(13:end));
  end
  
  set(gcf,'tag','ebsd_spatial');
  setappdata(gcf,'options',[extract_option(varargin,'antipodal'),...
    opts varargin]);
  
  axis equal tight
  fixMTEXplot(gca,varargin{:});
end




