function ebsd = fill(ebsd,cube,dx)
% extrapolate spatial EBSD data by nearest neighbour for tetragonal lattice
%
%% Input
% ebsd  -  @EBSD
% cube  -  a cube with extends [xmin xmax ymin ymax zmin zmax]
% dx    -  stepsize
%
%% Example
% fill(ebsd,extend(ebsd),.6)
%

%% extract spatial coordinates
X = get(ebsd,'xyz');
if numel(dx) == 1
  dx(1:3) = dx;
end

%% generate regular grid and interpolate

c = 1:size(X,1);
dim = size(X,2);

if dim  == 2
  [xi,yi] = meshgrid(cube(1):dx(1):cube(2),cube(3):dx(2):cube(4));
  ci = interp2(X(:,1),X(:,2),c,xi,yi,'nearest')
else
  [xi,yi,zi] = meshgrid(cube(1):dx(1):cube(2),cube(3):dx(2):cube(4),cube(5):dx(3):cube(6));
  ci = interp3(X(:,1),X(:,2),X(:,3),c,xi,yi,zi,'nearest')
end

%% fill ebsd variable
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

