function ebsd = fill(ebsd,cube,dx)
% extrapolate spatial EBSD data by nearest neighbour for tetragonal lattice
%
%% Input
% ebsd  -  an @EBSD object
% cube  -  a cube with extends [xmin xmax ymin ymax zmin zmax]
% dx    -  stepsize
%
%% Example
% fill(ebsd,extend(ebsd),.6)
%


X = get(ebsd,'X');
if numel(dx) == 1
  dx(1:3) = dx;
end

dim = size(X,2);
if dim  == 2
  [x,y] = meshgrid(cube(1):dx(1):cube(2),cube(3):dx(2):cube(4));
  Xt = [x(:) y(:)];
else
  [x,y,z] = meshgrid(cube(1):dx(1):cube(2),cube(3):dx(2):cube(4),cube(5):dx(3):cube(6));
  Xt = [x(:) y(:) z(:)];
end

Xt(ismember(Xt,X,'rows'),:) = []; % dont process points allready exist

if size(Xt,1) == 0, return; end

Zbuffer = Inf(size(Xt,1),1);
Z = zeros(size(Xt,1),1);
sx = size(X,1);

vprogress(0,sx);
for k=1:sx
  vprogress(k,sx);
  
  % compute distances
  d = zeros(size(Xt,1),1);
  for a=1:dim
    d = d + (X(k,a) - Xt(:,a)).^2;
  end
  d = sqrt(d);
  
  nd = d<Zbuffer;
  Zbuffer(nd) = d(nd);
  Z(nd) = k;
end

% copy data
smpsz = sampleSize(ebsd);
cs = cumsum([0,smpsz]);

for l=1:numel(ebsd)
  nd = cs(l) < Z & Z <= cs(l+1);
  Zt = Z(nd,:)-cs(l);
  
  ebsd(l).X = [ebsd(l).X; Xt(nd,:)];
  ebsd(l).orientations = [ebsd(l).orientations; ebsd(l).orientations(Zt)];
  
  ebsd_fields = fields(ebsd(l).options);
  for f = 1:length(ebsd_fields)
    if numel(ebsd(l).options.(ebsd_fields{f})) == smpsz(l)
      ebsd(l).options.(ebsd_fields{f}) = [ebsd(l).options.(ebsd_fields{f}); ...
        ebsd(l).options.(ebsd_fields{f})(Zt,:)];
    end
  end
end


function vprogress(k,n)
if n > 100, progress(k,n), end

