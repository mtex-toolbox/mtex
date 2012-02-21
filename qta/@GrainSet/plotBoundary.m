function plotBoundary(grains,varargin)
% colorize grain boundaries
%
%% Input
%  grains  - @Grain2d | @Grain3d
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
%
%    *  @quaternion | @rotation | @orientation -- plot grain boundaries with
%            a specified misorientation
%
%            plot(grains,'property',...
%               rotation('axis',zvector,'angle',60*degree))
%
%    *  @Miller | @vector3d -- plot grain boundaries such as specified
%            crystallographic face are parallel. use with option 'delta'
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

obj.Vertices = full(grains.V);
obj.Faces    = full(grains.F);

if check_option(varargin,{'sub','subboundary','internal','intern'})
  I_FD = abs(double(grains.I_FDsub));
elseif  check_option(varargin,{'external','ext','extern'})
  I_FD = abs(double(grains.I_FDext));
else % otherwise select all boundaries
  I_FD = grains.I_FDext | grains.I_FDsub;
end

if isa(grains,'Grain2d')
  
  [obj.Vertices(:,1),obj.Vertices(:,2),lx,ly] = fixMTEXscreencoordinates(obj.Vertices(:,1),obj.Vertices(:,2),varargin{:});
  
else
  
  [ig,ig,lx,ly] = fixMTEXscreencoordinates([],[],varargin{:});
  
end

% set direction of x and y axis
property = get_option(varargin,'property','none');

if ~ischar(property)
  propval  = property;
  property = class(property);
else
  property = lower(property);
  propval = [];
end


%%

if strcmpi(property,'none') % default case
  
  [i,d] = find(I_FD);
  obj.Faces = obj.Faces(i,:);
  
  if isa(grains,'Grain3d')
    
    obj.EdgeColor = 'k';
    obj.FaceColor = 'r';
    
  elseif isa(grains,'Grain2d')
    
    obj.EdgeColor = 'r';
    obj.FaceColor = 'none';
    
  end
  
else
  
  phase = get(grains.EBSD,'phase');
  phaseMap = get(grains.EBSD,'phaseMap');
  
  CS = get(grains,'CSCell');
  SS = get(grains,'SS');
  r         = get(grains.EBSD,'quaternion');
  phase     = get(grains.EBSD,'phase');
  isIndexed = ~isNotIndexed(grains.EBSD);
  
  sel = find(sum(I_FD,2) == 2);
  [d,i] = find(I_FD(sel,any(grains.I_DG,2))');
  Dl = d(1:2:end); Dr = d(2:2:end);
  
  % delete adjacenies between different phase and not indexed measurements
  f = sel(i(1:2:end));
  use = phase(Dl) == phase(Dr) & isIndexed(Dl) & isIndexed(Dr);
  
  Dl = Dl(use); Dr = Dr(use);
  phase = phase(Dl);
  f = f(use);
  
  % find and delete adjacencies
  epsilon = get_option(varargin,{'deltaAngle','angle','delta'},5*degree,'double');
  
  for p=1:numel(phaseMap)
    currentPhase = phase == phaseMap(p);
    if any(currentPhase)
      
      o_Dl = orientation(r(Dl(currentPhase)),CS{p},SS);
      o_Dr = orientation(r(Dr(currentPhase)),CS{p},SS);
      
      m  = o_Dl.\o_Dr; % misorientation
      
      prop(currentPhase,:) = calcBoundaryColorCode(m,...
        property,propval,epsilon,varargin{:});
      
    end
  end  
  
  if islogical(prop)
    f(~prop) = [];
    prop = zeros(nnz(prop),3);
  elseif any(~isfinite(prop(:)))
    del = any(~isfinite(prop),2);
    f(del) = [];
    prop(del,:) = [];
  end  
  
  obj.Faces = obj.Faces(f,:);
  
  if isa(grains,'Grain2d') % 2-dimensional case
    
    obj.Faces(:,3) = size(obj.Vertices,1)+1;
    obj.Vertices(end+1,:) = NaN;
    obj.Vertices = obj.Vertices(obj.Faces',:);
    obj.Faces = 1:size(obj.Vertices,1);
    
    prop = reshape(repmat(prop,1,3)',size(prop,2),[])';
    obj.EdgeColor = 'flat';
    obj.FaceColor = 'none';
    
  elseif isa(grains,'Grain3d')
    
    obj.FaceColor = 'flat';
    
  end
  
  obj.FaceVertexCData = prop;
end


if isempty(obj.Faces)
  warning('no Boundary to plot');
  return
end


isString = cellfun('isclass',varargin,'char');
varargin(isString) = regexprep(varargin(isString),'\<c\olor','EdgeColor');


%%

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

varargin = set_default_option(varargin,...
  {'name', [property ' plot of ' inputname(1) ' (' grains.comment ')']});

% clear up figure
newMTEXplot('renderer','opengl',varargin{:});
xlabel(lx);ylabel(ly);

h = optiondraw(patch(obj),varargin{:});

fixMTEXscreencoordinates('axis'); %due to axis;

axis equal tight
fixMTEXplot(varargin{:});



function val = calcBoundaryColorCode(m,property,propval,epsilon,varargin)

switch lower(property)
  
  case 'angle'
    
    val = angle(m(:))/degree;
    
  case 'double'
    
    m = angle(m(:));
    val = false(size(m));
    
    val(min(propval) <= m(:) & m(:) <= max(propval)) = true;
    
    
  case 'misorientation'
    
    cc = get_option(varargin,'colorcoding','ipdf');
    
    val = orientation2color(m(:),cc,varargin{:});
    
  case {'quaternion','rotation','orientation','so3grid'}
    
    epsilon = get_option(varargin,'delta',5*degree,'double');
    
    val = any(find(m,propval,epsilon),2);
    
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
    %     sigma(sigma>100 | sigma <3) = NaN;
    %     val = NaN(size(m(:)));
    %     val(~rm) = sigma;
    %
  case {'miller','vector3d','cell'}
    % special rotation, such that m*h_1 = h_2,
    
    epsilon = get_option(varargin,'delta',5*degree,'double');
    
    if strcmp(property,'cell'),
      h = [propval{[1 end]}];
    else
      h = propval;
    end
    
    if isa(h,'Miller')
      h = ensureCS(get(m,'CS'),ensurecell(h));
    end
    
    h = ensurecell(h);
    
    gr = symmetrise(vector3d(h{end}),get(m,'CS'));
    gh = symmetrise(vector3d(h{1}),get(m,'CS'));
    
    p = quaternion(m(:))*gh;
    if numel(h) > 1
      p =  [p quaternion(inverse(m(:)))*gh];
    end
    
    val =  false(size(m(:)));
    for l=1:numel(gr)
      val = val | min(angle(p,gr(l)),[],2) < epsilon;
    end
    
    %  val = any(reshape(angle(symmetrise(m)*pval(1),pval(end))<epsilon,[],numel(m)),1)';
    
end


