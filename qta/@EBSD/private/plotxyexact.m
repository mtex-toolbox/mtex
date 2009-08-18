function plotxyexact(x,y,d,varargin)
% plot d along x and y
% plot(rotate(ebsd,45*degree,'spatial'),'exact')

[x,y, lx,ly] = fixMTEXscreencoordinates(x,y,varargin{:});

%% a unit cell

unitcell = @(s,d,rot) exp(1i*(pi/s+rot:pi/(s/2):2*pi+rot))*1./sqrt((s/2))*d;

%% estimate grid resolution

dxy = get_option(varargin,'GridResolution',[]);

if isempty(dxy)
  rndsmp = [ (1:sum(1:length(x)<=100))'; unique(fix(1+rand(200,1)*(length(x)-1)))];

  xx = repmat(x(rndsmp),1,length(rndsmp));
  yy = repmat(y(rndsmp),1,length(rndsmp));
  dist = abs(sqrt((xx-xx').^2 + (yy-yy').^2));

  dxy = min(dist(dist>eps)); 
end

%% Generate a Unit Cell

celltype = get_option(varargin,'GridType','automatic');
cellrot = get_option(varargin,'GridRotation',0*degree);

if ischar(celltype)
  switch lower(celltype) 
    case 'automatic'  % try to extract an unit cell
      cx = (max(x)-min(x))/2+min(x);
      cy = (max(y)-min(y))/2+min(y);
      
      fc = 1;  sublattice = 0;
      while sum(sublattice) < 30  && fc <  2^10
        sublattice = x > cx-fc*dxy & x < cx+fc*dxy & y > cy-fc*dxy & y < cy+fc*dxy;
        fc = fc*2;
      end
      
      xy_s = [x(sublattice) y(sublattice)]; 
      
      if length(xy_s) < 30,        
        warning('MTEX:plotspatial:UnitCell',['The automatic generation of a unit cell may have failed! \n',...
                                             'Please specify more parameters!']);
        plotxyexact(x,y,d,'GridType','tetragonal')     
        return
      end
      
      [v c] = voronoin(xy_s);
     
      area = @(x,y) abs(0.5.*sum(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)));
      area = cellfun(@(c1) area(v([c1 c1(1)],1),v([c1 c1(1)],2)),c);
      
      [a ci] = min(area);
           
      cx = v(c{ci},1) - xy_s(ci,1);
      cy = v(c{ci},2) - xy_s(ci,2);
      
      if mod(length(cx),2), 
        warning('MTEX:plotspatial:UnitCell',['The automatic generation of a unit cell may have failed! \n',...
                                             'Please specify more parameters!']);
        plotxyexact(x,y,d,'GridType','tetragonal')     
        return
      end
      
    otherwise
      switch lower(celltype) 
        case 'tetragonal'
          c = unitcell(4,dxy,cellrot);      
        case 'hexagonal'      
          c = unitcell(6,dxy,cellrot);
        case 'circle'
          c = unitcell(16,dxy,cellrot);      
        otherwise
          error('MTEX:plotspatial:UnitCell','Unknown option')
      end
      [cx cy] = fixMTEXscreencoordinates(real(c(:)),imag(c(:)),varargin{:});
  end
end


%% generate a surface 

x1 = repmat(x',length(cx),1) + repmat(cx,1,length(x));
y1 = repmat(y',length(cy),1) + repmat(cy,1,length(y));
fac = reshape( 1:numel(x1),length(cx),length(x))';

h = patch('Vertices',[x1(:) y1(:)],'Faces',fac,'FaceVertexCData',d,...
  'FaceColor','flat','EdgeColor','none');

optiondraw(h,varargin{:});

xlabel(lx); ylabel(ly);
fixMTEXplot;
