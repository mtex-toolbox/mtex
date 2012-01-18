function plotGrains(grains,varargin)
% colorize grains
%
%% Input
%  grains  - @Grain3d
%% Options
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
%% See also
% Grain2d/plotGrains

newMTEXplot;

obj.Vertices = get(grains,'V');
obj.Faces    = get(grains,'F');

obj.EdgeColor = 'none';
obj.FaceColor = 'flat';


phaseMap = get(grains,'phaseMap');
phase = get(grains,'phase');


nphase = numel(phaseMap);
X = cell(1,nphase);
d = [];
for k=1:nphase
  iP =  phase == phaseMap(k);  
  [d(iP,:),property] = calcColorCode(grains,iP,varargin{:});
end

I_FD = get(grains,'I_FDext');
I_DG = get(grains,'I_DG');

[f,g] = find(double(I_FD)*I_DG(:,any(I_DG)));

obj.Faces           = obj.Faces(f,:);
obj.FaceVertexCData = d(g,:);

if isempty(obj.Faces)
  warning('nothing to plot');
else
  h = optiondraw(patch(obj),varargin{:});
  fixMTEXplot;
  optiondraw(h,varargin{:});
end



