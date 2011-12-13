function plotBoundary(grains,varargin)



newMTEXplot;

obj.Vertices = full(grains.V);
obj.Faces    = full(grains.F);

if check_option(varargin,{'sub','subboundary','internal','intern'})
  I_FD = grains.I_FDsub;
elseif  check_option(varargin,{'external','ext','extern'})
  I_FD = grains.I_FDext;
else % otherwise select all boundaries
  I_FD = grains.I_FDext | grains.I_FDsub;
end

if isa(grains,'Grain2d')
  
  [obj.Vertices(:,1),obj.Vertices(:,2),lx,ly] = fixMTEXscreencoordinates(obj.Vertices(:,1),obj.Vertices(:,2),varargin{:});
  
else
  
  [ig,ig,lx,ly] = fixMTEXscreencoordinates([],[],varargin{:});
  
end

% set direction of x and y axis
xlabel(lx);ylabel(ly);
property = lower(get_option(varargin,'property','none'));

if ~ischar(property)
  propval  = property;
  property = class(property);
end

if strcmpi(property,'none') % default case
  
  [i,d] = find(I_FD);
  obj.Faces = obj.Faces(i,:);
  
  if isa(grains,'Grain3d')
    
    obj.EdgeColor = 'k';
    obj.FaceColor = 'r';
    
  else
    
    obj.EdgeColor = 'r';
    
  end
  
else
  
  sel = find(sum(I_FD,2) == 2);
  
  [d,i] = find(I_FD(sel,any(grains.I_DG,2))');
  
  pairs = reshape(d,2,[]);
  f = sel(i(1:2:end));
  
  phase = get(grains.EBSD,'phase');
  phaseMap = get(grains,'phaseMap');
  
  switch property
    
    case {'phase','phaseboundary'}
      
      val = phase(pairs(1,:)) ~= phase(pairs(2,:));
      prop = zeros(nnz(val),3);
      f(~val) = [];
      
    case 'phasetransition'
      
      [ignore,ignore,phase] = unique(phase);
      phase = sort(phase(pairs));
      prop = sub2ind( [numel(phaseMap) numel(phaseMap)],phase(1,:),phase(2,:))';
      [ignore,ignore,prop] = unique(prop);
      
    otherwise % something orientation related
      
      CS = get(grains,'CSCell');
      SS = get(grains,'SS');
      r       = get(grains.EBSD,'rotations');
      phase   = get(grains.EBSD,'phase');
      notIndexed = ~isNotIndexed(grains.EBSD);
      
      phase = phase(pairs);
      notIndexed = notIndexed(pairs);
      
      del = diff(phase)~=0 | any(~notIndexed);
      phase(:,del) = [];
      pairs(:,del) = [];
      f(del) = [];
      
      prop = [];
      for k=1:numel(phaseMap)
        sel = phase == phaseMap(k);
        if any(sel(:))
          phasepair = reshape(pairs(sel),2,[]);
          o   = orientation(r(phasepair),CS{k},SS);
          mo  = o(1,:).\o(2,:); % misorientation
          
          switch property
            
            case 'angle'
              
              val = angle(mo(:))/degree;
              
            case 'misorientation'
              
              cc = get_option(varargin,'colorcoding','ipdf');
              
              val = orientation2color(mo(:),cc,varargin{:});
              
            case {'quaternion','rotation','orientation','SO3Grid'}
              
              epsilon = get_option(varargin,'delta',5*degree,'double');
              
              val = any(find(mo,propval,epsilon),2);
              
            case {'Miller','vector3d'}
              
              epsilon = get_option(varargin,'delta',5*degree,'double');
              val = any(reshape(angle(symmetrise(mo)*propval,propval)<epsilon,[],numel(mo)),1)';
              
          end
          
          prop(sel(1,:),:) = val;
          
        end
      end
      
      if islogical(val)        
        f(~prop) = [];
        prop = zeros(nnz(prop),3);
      end
  end
  
  obj.Faces = obj.Faces(f,:);
  
  if isa(grains,'Grain2d') % 2-dimensional case
    
    obj.Faces(:,3) = size(obj.Vertices,1)+1;
    obj.Vertices(end+1,:) = NaN;
    obj.Vertices = obj.Vertices(obj.Faces',:);
    obj.Faces = 1:size(obj.Vertices,1);
    
    prop = reshape(repmat(prop,1,3)',size(prop,2),[])';
    obj.EdgeColor = 'flat';
    
  elseif isa(grains,'Grain3d')
    
    obj.FaceColor = 'flat';
    
  end
  
  obj.FaceVertexCData = prop;
end


if isempty(obj.Faces)
  warning('no Boundary to plot');
else
  h = optiondraw(patch(obj),varargin{:});
  fixMTEXplot;
  set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});
end



