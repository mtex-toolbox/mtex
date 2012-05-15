function [f,dist] = specialBoundary(grains,propval,varargin)
% classifies the misorientation present on grain boundaries 
%
%% Input
% grains   - @GrainSet
%% Options
%  property - colorize a special grain boundary property, variants are:
%
%    * |'phase'| -- boundaries between different phases
%
%    * |'phaseTransition'|  -- colorize boundaries according to phase change
%                   (same phase, different phase).
%    * |'angle'| -- misorientation angle between two neighboured ebsd
%            measurements on the boundary.
%    * |'misorientation'| -- calculate the misorientation on the grain boundary
%            between two ebsd measurements and [[orientation2color.html,colorize]]
%            it after a choosen colorcoding, i.e.
%
%            plot(grains,'property','misorientation',...
%              'colorcoding','ipdf')
%    * double -- a single number for which the misorientation  angle is lower or 
%            an interval [a b]
%
%    *  @quaternion | @rotation | @orientation -- plot grain boundaries with
%            a specified misorientation
%
%            plot(grains,'property',...
%               rotation('axis',zvector,'angle',60*degree))
%
%    *  @Miller -- plot grain boundaries such as specified
%            crystallographic face are parallel. use with option 'delta'
%
%    *  @vector3d -- axis of misorientation
%
%  delta - specify a searching radius for special grain boundary
%            (default 5 degrees), if a orientation or crystallographic face
%            is specified.
%
%% Flags
% subboundary - only plot boundaries within a grain which do not match the grain boundary
%         criterion
% extern - only plot grain--boundaries to other grains.
%
%% Output
% f    - list of faces of the @GrainSet that satisfy the specified criterion
% dist - distance to critierion
%
%% See also
% GrainSet/merge GrainSet/plotBoundary


%% properties of underlaying EBSD data

CS        = get(grains.EBSD,'CSCell');
SS        = get(grains.EBSD,'SS');
r         = get(grains.EBSD,'quaternion');
phase     = get(grains.EBSD,'phase');
phaseMap  = get(grains.EBSD,'phaseMap');
isIndexed = ~isNotIndexed(grains.EBSD);

%% which boundaries should be considered

if check_option(varargin,{'ext','external'})
  I_FD = logical(grains.I_FDext);
elseif check_option(varargin,{'int','internal'})
  I_FD = logical(grains.I_FDsub);
else
  I_FD = grains.I_FDext | grains.I_FDsub;
end

%% retrive adjacent measurements and its face

doubleEdges = find(sum(I_FD,2) == 2);
[d,f] = find(I_FD(doubleEdges,any(grains.I_DG,2))');

% edges
f = doubleEdges(f(1:2:end));
% index of left and right voronoi cell
Dl = d(1:2:end);
Dr = d(2:2:end);

%%

if nargin < 2
  propval = pi;
end

if strcmpi(propval,'phase')
  
  boundarySegment = phase(Dl) ~= phase(Dr);
  dist = zeros(nnz(boundarySegment),1);
  
elseif strcmpi(propval,'phasetransition')
  
  phaseTransitions = sort([phase(Dl),phase(Dr)],2);
  
  nph = numel(phaseMap);
  [i,i,dist] = unique(sub2ind([nph nph],...
    phaseTransitions(:,1),phaseTransitions(:,2)));
  
  boundarySegment = true(size(f));
  
else
  % otherwise its some orientation property
  
  % consider only boundaries between indexed measurements
  use = isIndexed(Dl) & isIndexed(Dr);
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
      % left phase
      CSl = CS{Pl(p) == phaseMap};
      % right phase
      CSr = CS{Pr(p) == phaseMap};
      
      [boundarySegment(segment),dist(segment,:)] = checkCriterion(...
        r(Dl(segment)),r(Dr(segment)),CSl,CSr,SS,propval,varargin{:});
      
    end
    
  end
  
end

f = f(boundarySegment);
dist = dist(boundarySegment,:);



function [isCriterion,dist,m] = checkCriterion(Rl,Rr,CSl,CSr,SS,propval,varargin)

m = orientation(Rl,CSl,SS) .\ orientation(Rr,CSr,SS);

% check options
searchRadius = get_option(varargin,...
  {'deltaAngle','angle','delta'},2*degree,'double');

dist = zeros(size(m));

switch class(propval)
  
  case 'char'
    
    isCriterion = true(size(m));
    
    if strcmpi(propval,'angle')
      
      dist = angle(m)/degree;
      
    elseif strcmpi(propval,'misorientation')
      
      dist = orientation2color(m(:),get_option(varargin,'colorcoding','ipdf'),varargin{:});
      
    end
    
    return
    
  case 'double'
    
    dist = angle(m);
    
    if isscalar(propval)
      
      searchRadius = propval;
      
    elseif isvector(propval)
      
      isCriterion = min(propval) <= dist & dist <= max(propval);
      m = m(isCriterion);
      return
      
    end
    
    
  case {'quaternion','rotation','orientation','SO3Grid'}
    
    dist = 2*acos(max(abs(dot_outer(m,propval)),[],2));
    
  case 'vector3d'
    
    dist = angle(axis(m),propval);
    
  case 'Miller'
    
    lh = ensureCS(get(m,'CS'),ensurecell(propval));
    rh = ensureCS(get(m,'SS'),ensurecell(propval));
    
    dist = angle(m*lh,rh);
    
  otherwise
    
    error('unknown property')
    
end

isCriterion = dist <= searchRadius;

m = m(isCriterion);



%% TODO
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



