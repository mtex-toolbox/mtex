function plotxyexact (x,y,d,varargin)
% plot d along x and y
% plot(rotate(ebsd,45*degree,'spatial'),'exact','GridRotation',45*degree)

[x,y, lx,ly] = fixMTEXscreencoordinates(x,y,varargin{:});

%% estimate grid resolution

dxy = get_option(varargin,'GridResolution',[]);

if isempty(dxy)
  rndsmp = [ (1:sum(1:length(x)<=175))'; unique(fix(1+rand(200,1)*(length(x)-1)))];

  xx = repmat(x(rndsmp),1,length(rndsmp));
  yy = repmat(y(rndsmp),1,length(rndsmp));
  dist = abs(sqrt((xx-xx').^2 + (yy-yy').^2));

  dxy = min(dist(dist>eps)); 
end

%% Generate a Unit Cell

celltype = get_option(varargin,'GridType','tetragonal');
cellrot = get_option(varargin,'GridRotation',0*degree);

if ischar(celltype)
  switch celltype 
    case 'tetragonal'
      c = exp(1i*(pi/4+cellrot:pi/2:pi*9/4+cellrot))*1./sqrt(2)*dxy;
    case 'hexagonal'      
      c = exp(1i*(pi/6+cellrot:pi/3:pi*13/6+cellrot))*sin(pi/6)/cos(pi/6)*dxy;
  end
end

[cx cy] = fixMTEXscreencoordinates(real(c(:))',imag(c(:))',varargin{:});

%% generate a surface 

x1 = (repmat(x,1,length(cx))+repmat(cx,length(x),1))';
y1 = (repmat(y,1,length(cx))+repmat(cy,length(y),1))';
fac = reshape(1:numel(x1),length(c),length(x))';

h = patch('Vertices',[x1(:) y1(:)],'Faces',fac,'FaceVertexCData',d,...
  'FaceColor','flat','EdgeColor','none');

optiondraw(h,varargin{:});

xlabel(lx); ylabel(ly);
fixMTEXplot;
