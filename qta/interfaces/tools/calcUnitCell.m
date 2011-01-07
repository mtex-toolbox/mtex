function unitCell = calcUnitCell(xy,varargin)
% compute the unit cell for an EBSD data set
%
%% Input
%  xy - spatial coordinates
%
%% Output
%  unitCell - coordinates of the unit cell
%
%%


% remove dublicates from the coordinates
xy = unique(xy,'first','rows');

% make live
x = xy(:,1);
y = xy(:,2);
  
%% estimate grid resolution
dxy = get_option(varargin,'GridResolution',[]);
if isempty(dxy), dxy =estimateGridResolution(x,y); end

%% Generate a Unit Cell

celltype = get_option(varargin,'GridType','automatic');
cellrot = get_option(varargin,'GridRotation',0*degree);

if ischar(celltype)
  switch lower(celltype)
    
    % try to extract an unit cell
    case 'automatic'
      

      
      % compute Voronoi decomposition
      [v c] = voronoin(xy,{'Qz'});
      
      % compute the area of all Voronoi cells
      areaf = @(x,y) abs(0.5.*sum(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)));
      areaf = cellfun(@(c1) areaf(v([c1 c1(1)],1),v([c1 c1(1)],2)),c);
      
      % the unit cell should be the Voronoi cell with the smalles area
      [a ci] = min(areaf);
      
      % compute vertices of the unit cell
      ux = v(c{ci},1) - xy(ci,1);
      uy = v(c{ci},2) - xy(ci,2);
      
      % check that the unit cell is correct
      if mod(length(ux),2) || ~all(diff(diff(ux).^2 + diff(uy).^2) < dxy*10^-2)
        warning('MTEX:plotspatial:UnitCell',['The automatic generation of a unit cell may have failed! \n',...
          'Please specify more parameters!']);
        [v c] = spatialdecomposition(xy,'GridType','tetragonal',varargin{:});
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
      cx = real(c(:));
      cy = imag(c(:));
  end
end


function regularPoly()
% the vertices of a regular polygon with s vertices,
% diamter d, rotated by rot
unitcell = @(s,d,rot) exp(1i*(pi/s+rot:pi/(s/2):2*pi+rot))*1./sqrt((s/2))*d;

function dxy = estimateGridResolution(x,y)

rndsmp = [ (1:sum(1:length(x)<=100))'; unique(fix(1+rand(200,1)*(length(x)-1)))];

xx = repmat(x(rndsmp),1,length(rndsmp));
yy = repmat(y(rndsmp),1,length(rndsmp));
dist = abs(sqrt((xx-xx').^2 + (yy-yy').^2));
dxy = min(dist(dist>eps)); 


% % center of the region
%       cx = (max(x)+min(x))/2;
%       cy = (max(y)+min(y))/2;
%       
%       % find a centered sublattice 
%       fc = 1;  sublattice = 0;
%       kl = min(500,length(xy));
%       
%       while sum(sublattice) <  kl && fc <  2^10 % find 500 points (or less)
%         sublattice = x > cx-fc*dxy & x < cx+fc*dxy & y > cy-fc*dxy & y < cy+fc*dxy;
%         fc = fc*2;
%       end
%       
%       % coordinates of this sublattice
%       xy_s = [x(sublattice) y(sublattice)];
%       
%       if length(xy_s) < kl,
%         warning('MTEX:plotspatial:UnitCell',['The automatic generation of a unit cell may have failed! \n',...
%           'Please specify more parameters!']);
%         [v c] = spatialdecomposition(xy,'GridType','tetragonal',varargin{:});
%         return
%       end

