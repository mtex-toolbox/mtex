function plotBoundary(grains,varargin)



newMTEXplot;

V = grains.V;
F = grains.F;

if check_option(varargin,{'sub','subboundary','internal','intern'})
  I_FD = grains.I_FDsub;
elseif  check_option(varargin,{'external','ext','extern'})
  I_FD = grains.I_FDext;
else % otherwise select all boundaries
  I_FD = grains.I_FDext | grains.I_FDsub;
end


if isa(grains,'Grain2d')
  
  [V(:,1),V(:,2),lx,ly] = fixMTEXscreencoordinates(V(:,1),V(:,2),varargin{:});
  
else
  
  [ig,ig,lx,ly] = fixMTEXscreencoordinates([],[],varargin{:});
  
end

% set direction of x and y axis
xlabel(lx);ylabel(ly);
prop = lower(get_option(varargin,'property','none'));

switch prop
  case 'angle'

    sel = find(sum(I_FD,2) == 2);
    [d,i] = find(I_FD(sel,:)');
    
    pairs = reshape(d,2,[]);
    i = reshape(sel(i),2,[]);
    i = i(1,:);
    
    phase = get(grains.EBSD,'phase');
    phase = phase(pairs);
    del = diff(phase)~=0;
    
    phase(:,del) = [];
    pairs(:,del) = [];
    i(del) = [];
    
    r = get(grains.EBSD,'rotations');
    cs = get(grains.EBSD,'CSCell');
    ss = get(grains.EBSD,'SS');    
    
    uphase = unique(phase);
    prop = zeros(size(i));
    for k=1:numel(uphase)
      sel = phase == uphase(k);
      
      o = orientation(r(reshape(pairs(sel),2,[])),cs{uphase(k)},ss);
      prop( sel(1,:)) =  angle(o(1,:),o(2,:))./degree;
    end
    
    F = F(i,:);
    
    if isa(grains,'Grain2d') % 2-dimensional case
      
      F(:,3) = size(V,1)+1;
      V(end+1,:) = NaN;
      V = reshape(V(F',:),[],2);
      
      prop = reshape(repmat(prop,3,1),1,[]);
      F = 1:size(V,1);
      
      options.EdgeColor = 'flat';
    
    elseif isa(grains,'Grain3d')
      
      options.FaceColor = 'flat';

      
    end
    
    options.FaceVertexCData = prop(:);
        
  otherwise
    
    [i,d] = find(I_FD);
    F = F(i,:);
    
    if isa(grains,'Grain3d')
      
      options.EdgeColor = 'k';
      options.FaceColor = 'r';
      
    else
      
      options.EdgeColor = 'r';
      
    end
    
end

h = patch('Vertices',V,'Faces',F,options);


fixMTEXplot;
set(gcf,'ResizeFcn',{@fixMTEXplot,'noresize'});
optiondraw(h,varargin{:});


