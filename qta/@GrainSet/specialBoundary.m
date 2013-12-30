function [f,dist] = specialBoundary(grains,property,varargin)
% classifies the misorientation present on grain boundaries
%
% Input
%  grains   - @GrainSet
%  property - colorize a special grain boundary property, variants are:
%
%    * |'phase'| -- boundaries between different phases
%
%    * |'phaseTransition'|  -- colorize boundaries according to phase change
%                   (same phase, different phase).
%
%    * |'angle'| -- misorientation angle between two neighboured ebsd
%            measurements on the boundary.
%
%    * |'misorientation'| -- calculate the misorientation on the grain boundary
%            between two ebsd measurements and [[orientation2color.html,colorize]]
%            it after a choosen colorcoding, i.e.
%
%            plotBoundary(grains,'property','misorientation',...
%              'colorcoding','ipdfHSV')
%
%    * double -- a single number |a| for which the misorientation angle
%            between two neighbored measurements is lower or an interval [a b]
%
%    *  @quaternion | @rotation | @orientation -- plot grain boundaries with
%            a specified misorientation
%
%            plotBoundary(grains,'property',...
%               rotation('axis',zvector,'angle',60*degree))
%
%    *  @Miller -- plot grain boundaries such as specified
%            crystallographic face are parallel. use with option 'delta'
%
%    *  @vector3d -- axis of misorientation
%
% Options
%  delta - specify a searching radius for special grain boundary
%            (default 5 degrees), if a orientation or crystallographic face
%            is specified.
%
%  ExclusiveGrains - a subset of grains of the given grainset marked in a
%    logical Nx1 array
%
%  ExclusiveNeighborhoods - an adjacency matrix of neighbored grains or a
%    Nx2 array indexing the neigborhoods
%
%  TripleJunction - return faces between two adjacent grains satisfying the
%    input property, if there is a triple junction with a thrid grain,
%    satisfying the property specified after TripleJunction.
%
%  ThirdCommonGrain - return faces between two adjacent grains satisfying the
%    input property, if there is a third commongrain, satisfying the
%    property specified after ThirdCommonGrain.
%
% Flags
%  internal - only plot boundaries within a grain which do not match the grain boundary
%             criterion
%  external - only plot grain--boundaries to other grains.
%
%  PhaseRestricted - do not consider different phases when compting misorientations
%
% Syntax
%
%   % faces that satisfy |property|
%   [f,dist] = specialBoundary(grains,property) 
%
%   % faces whos misorientation angle lies between 0 and 10 degrees
%   f = specialBoundary(grains,[0 10]*degree) 
%
%   % faces of two adjacent grains with a CSL(3) boundary 
%   f = specialBoundary(grains,CSL(3)) 
%
%   % faces grains with special boundary CSL9 having a boundary to a third
%   % grain in common with CSL(3)
%   f = specialBoundary(grains,CSL(9),'ThirdCommonGrain',CSL(3)) 
%
% Output
%  f    - list of faces of the @GrainSet that satisfy the specified criterion
%  dist - distance to critierion
%
% See also
% GrainSet/merge GrainSet/plotBoundary

grains = subSet(grains,get_option(varargin,'ExclusiveGrains',true(size(grains))));

% which boundaries should be considered

if check_option(varargin,{'ext','external'})
  I_FD = logical(grains.I_FDext);
elseif check_option(varargin,{'int','internal'})
  I_FD = logical(grains.I_FDint);
else
  I_FD = grains.I_FDext | grains.I_FDint;
end

if check_option(varargin,'ExclusiveNeighborhoods') && ~check_option(varargin,'ExclusiveGrains')
  % delete faces that satisfy the criterion
  I_FG = I_FD*double(grains.I_DG);
  
  exNeigbor = get_option(varargin,'ExclusiveNeighborhoods');
  if issparse(exNeigbor)
    [i,j] = find(exNeigbor);
  else
    g = find(any(grains.I_DG));
    i = g(exNeigbor(:,1));
    j = g(exNeigbor(:,2));
  end
  I_FD(~(any(I_FG(:,i) & I_FG(:,j),2)),:) = false;
end

%

if check_option(varargin,'ThirdCommonGrain')
  
  property2 = get_option(varargin,'ThirdCommonGrain');
  varargin = delete_option(varargin,'ThirdCommonGrain');
  
  [f,dist] = thirdCommonGrainFaces(grains,I_FD,property,property2,varargin{:});
  
  return
  
elseif check_option(varargin,'TripleJunction')
  
  property2 = get_option(varargin,'TripleJunction');
  varargin = delete_option(varargin,'TripleJunction');
  
  [f, dist] = tripleJunctionFaces(grains,I_FD,property,property2,varargin{:});
  
  return
  
end

%

if nargin < 2 || isempty(property)
  
  f = find(any(I_FD,2));
  dist = false;
  
else
  % retrive adjacent measurements and its face
  
  doubleEdges = find(sum(I_FD,2) == 2);
  [d,f] = find(I_FD(doubleEdges,any(grains.I_DG,2))');
  
  % edges
  f = doubleEdges(f(1:2:end));
  % index of left and right voronoi cell
  Dl = d(1:2:end);
  Dr = d(2:2:end);
  
  % classify the boundary segment
  
  % phase properties of underlaying EBSD data
  phase     = grains.ebsd.phaseId;
  phaseMap  = grains.phaseMap;
  
  if strcmpi(property,'phase')
    
    boundarySegment = phase(Dl) ~= phase(Dr);
    dist = true(size(boundarySegment));
    
  elseif strcmpi(property,'phasetransition')
    
    phaseTransitions = sort([phase(Dl),phase(Dr)],2);
    
    nph = numel(phaseMap);
    [i,i,dist] = unique(sub2ind([nph nph],...
      phaseTransitions(:,1),phaseTransitions(:,2)));
    
    boundarySegment = true(size(f));
    
  else
    % otherwise its some orientation property
    CS        = grains.CS;
    SS        = symmetry;
    r         = grains.meanRotation;
    isIndexed = ~isNotIndexed(grains.ebsd);
    
    % consider only boundaries between indexed measurements
    use = isIndexed(Dl) & isIndexed(Dr);
    
    if check_option(varargin,'PhaseRestricted')
      use = use & phase(Dl) == phase(Dr);
    end
    
    Dl = Dl(use);
    Dr = Dr(use);
    f  = f(use);
    
    [Pl,Pr] = meshgrid(unique(phase));
    Pl = Pl(triu(true(size(Pl))));
    Pr = Pr(triu(true(size(Pr))));
    
    %switch order of phase
    switchLeftRight = phase(Dl) < phase(Dr);
    
    Dltemp = Dl(switchLeftRight);
    Dl(switchLeftRight) = Dr(switchLeftRight);
    Dr(switchLeftRight) = Dltemp;
    
    boundarySegment = false(size(f));
    
    for p = 1:numel(Pl)
      
      segment = Pl(p) == phase(Dl) & Pr(p) == phase(Dr);
      
      if any(segment)
        % left crystal symmetry
        CSl = CS{Pl(p) == phaseMap};
        % right crystal symmetry
        CSr = CS{Pr(p) == phaseMap};
        
        [boundarySegment(segment),dist(segment,:)] = checkCriterion(...
          r(Dl(segment)),r(Dr(segment)),CSl,CSr,SS,property,varargin{:});
        
      end
      
    end
    
  end
  
  f = f(boundarySegment);
  
  dist = dist(boundarySegment,:);
  
end


function [isCriterion,dist,m] = checkCriterion(Rl,Rr,CSl,CSr,SS,property,varargin)

m = orientation(Rl,CSl,SS) .\ orientation(Rr,CSr,SS);

% check options
searchRadius = get_option(varargin,...
  {'deltaAngle','angle','delta'},2*degree,'double');

dist = zeros(size(m));

switch class(property)
  
  case 'char'
    
    isCriterion = true(size(m));
    
    if strcmpi(property,'angle')
      
      dist = angle(m);
      
    elseif strcmpi(property,'misorientation')
      
      dist = orientation2color(m(:),get_option(varargin,'colorcoding','ipdfHSV'),varargin{:});
      
    end
    
    return
    
  case 'double'
    
    dist = angle(m);
    
    if isscalar(property)
      
      searchRadius = property;
      
    elseif isvector(property)
      
      isCriterion = min(property) <= dist & dist <= max(property);
      m = m(isCriterion);
      return
      
    end
    
    
  case {'quaternion','rotation','orientation','SO3Grid'}

    qproperty = unique(CSl*inv(quaternion(property))*CSr);
    dist = 2*acos(max(abs(dot_outer(quaternion(m),qproperty)),[],2));
    % dist = 2*acos(max(abs(dot_outer(m,property)),[],2));
      
  case 'vector3d'
    
    dist = angle(axis(m),property);
    
  case 'Miller'
    
    lh = ensureCS(get(m,'CS'),ensurecell(property));
    rh = ensureCS(get(m,'SS'),ensurecell(property));
    
    dist = angle(m*lh,rh);
    
  otherwise
    
    error('unknown property')
    
end

isCriterion = dist <= searchRadius;

m = m(isCriterion);



% TODO (?)
%   case {'csl'}
%
%     ax = axis(m(:));
%     om = angle(m(:));
%     h = Miller(ax,get(m,'CS'));
%     hkl = get(h,'hkl');
%     rm = any(abs(rem(hkl,1))> 10^-5,2);
%     hkl = abs(round(hkl(~rm,:)));
%     mm = round( sqrt( sum(hkl.^2,2) )./tan(om(~rm)/2));
%     N = sum(mod([hkl mm],2),2);
%     alpha = N;
%     alpha(mod(N,2) == true) = 1;
%     sigma = sum([hkl mm].^2,2)./alpha;
%     sigma(sigma>10 | sigma <3) = NaN;
%     val = NaN(size(m(:)));
%     val(~rm) = sigma;


function [f,dist] = thirdCommonGrainFaces(grains,I_FD,property,property2,varargin)

% determin the special boundary faces
[f1, dist1] = specialBoundary(grains,property,varargin{:});
[f2, dist2] = specialBoundary(grains,property2,varargin{:});

[nF,nD] = size(I_FD);

clear dist2 nD

I_FD1 = I_FD;
I_FD2 = I_FD;

clear I_FD

% delete not used faces
I_FD1(~sparse(f1,1,1,nF,1),:) = false;
I_FD2(~sparse(f2,1,1,nF,1),:) = false;

% determine faces vs grains
I_FG1 = I_FD1*double(grains.I_DG);
I_FG2 = I_FD2*double(grains.I_DG);

% adjacent grains  with special boundaries
A_G1 = I_FG1'* I_FG1;
A_G1 = A_G1 - diag(diag(A_G1)); % no self reference
A_G2 = I_FG2'* I_FG2;
A_G2 = A_G2 - diag(diag(A_G2));

% left and right grain satisfying property 1 
[Gl,Gr] = find(A_G1);
% left and right grain having a grain in common that is adjacent with property 2 
[Gm,Gp] = find(A_G2(:,Gl) & A_G2(:,Gr));

% get these faces
f = find(any(I_FG1(:,Gl(Gp)) & I_FG1(:,Gr(Gp)),2));

% just for output
dist = sparse(f1,1,dist1,nF,1);
dist = full(dist(f));


function [f,dist] = tripleJunctionFaces(grains,I_FD,property,property2,varargin);

% determin the special boundary faces
[f1, dist1] = specialBoundary(grains,property,varargin{:});
[f2, dist2] = specialBoundary(grains,property2,varargin{:});
clear dist2

F  = double(grains.F);
nV = size(grains.V,1);
nF = size(I_FD,1);

% vertices vs faces satisfying special boundary 1
[i,j,v] = find(F(f1,:));
I_VF1 = sparse(v,f1(i),1,nV,nF);

% vertices vs faces satisfying special boundary 2
[i,j,v] = find(F(f2,:));
I_VF2 = sparse(v,f2(i),1,nV,nF);

clear F v i j

% vertices incident to grains
I_VG1 = logical(I_VF1*I_FD*grains.I_DG);
I_VG2 = logical(I_VF2*I_FD*grains.I_DG);

% vertices incident to more than 2 grains
trijunc = sum(I_VG1 | I_VG2,2)>2;

clear I_VG1 I_VG2

% adjacent faces at triple junction, i.e. they have at least one vertex in common
A_F = I_VF1(trijunc,:)' * I_VF2(trijunc,:);
A_F = A_F | A_F'; % just to be sure ...

clear trijunk

% faces incident to trijunct vertex
f = any(A_F,2) & sparse(f1,1,true,nF,1);

clear A_F

% faces vs grains
I_FG = I_FD*grains.I_DG;

% common faces of grains, that have a trijunct.
[g,fi] = find(I_FG(f,:)');
gl = g(1:2:end); % left grain
gr = g(2:2:end); % right grain

f = f1(any(I_FG(f1,gl) & I_FG(f1,gr),2));

% just for output
dist = sparse(f1,1,dist1,nF,1);
dist = full(dist(f));

