function [v c rind] = spatialdecomposition(xy,varargin)

if check_option(varargin,'unitcell') || ~check_option(varargin,'voronoi')
  
  unitcell = @(s,d,rot) exp(1i*(pi/s+rot:pi/(s/2):2*pi+rot))*1./sqrt((s/2))*d;

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
      case 'automatic'  % try to extract an unit cell
        cx = (max(x)-min(x))/2+min(x);
        cy = (max(y)-min(y))/2+min(y);

        fc = 1;  sublattice = 0;
        kl = min(500,length(xy));
        
        while sum(sublattice) <  kl && fc <  2^10 % find 500 points (or less)
          sublattice = x > cx-fc*dxy & x < cx+fc*dxy & y > cy-fc*dxy & y < cy+fc*dxy;
          fc = fc*2;
        end
        
        xy_s = [x(sublattice) y(sublattice)]; 

        if length(xy_s) < kl,        
          warning('MTEX:plotspatial:UnitCell',['The automatic generation of a unit cell may have failed! \n',...
                                               'Please specify more parameters!']);
          [v c] = spatialdecomposition(xy,'GridType','tetragonal',varargin{:});
          return
        end
        xy_s = unique(xy_s,'first','rows');
        [v c] = voronoin(xy_s,{'Qz'});

        areaf = @(x,y) abs(0.5.*sum(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)));
        areaf = cellfun(@(c1) areaf(v([c1 c1(1)],1),v([c1 c1(1)],2)),c);

        [a ci] = min(areaf);

        cx = v(c{ci},1) - xy_s(ci,1);
        cy = v(c{ci},2) - xy_s(ci,2);
        
        if mod(length(cx),2) || ~all(diff(diff(cx).^2 + diff(cy).^2) < dxy*10^-2)
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


  %% generate a surface 

  x1 = repmat(x',length(cx),1) + repmat(cx,1,length(x));
  y1 = repmat(y',length(cy),1) + repmat(cy,1,length(y));
  
  [v m n] = uniquepoint([x1(:) y1(:)],dxy/10);
   
  c = reshape( n, length(cx),length(x))';  
  
  if ~check_option(varargin,'plot')
    ct = cell(length(x),1);
    for k=1:length(c)
      ct{k} = c(k,:);
    end 
    c = ct;
  else
    rind = {1:size(c,1)};
    c = {c};    
  end
  
else
  augmentation = get_option(varargin,'augmentation','cube');
  
  %% extrapolate dummy coordinates %dirty
  switch lower(augmentation)
    case 'cube'   
      
      x = xy(:,1);
      y = xy(:,2);
      I = eye(2);
      
      dxy = get_option(varargin,'GridResolution',[]);
      if isempty(dxy), dy =estimateGridResolution(x,y); end 
      
      dxy = [0; dy/2];
      R = @(rot) [cos(rot) -sin(rot); sin(rot) cos(rot)];
      
      k = convhulln(xy);
      k = [k(:,1);k(1)];
      
      pxy = xy(k,:);     
      
      % erase linear dependend lines
      det = x(k(1:end-1)).*y(k(2:end)) - x(k(2:end)).*y(k(1:end-1));
      k = k(~[false; logical(diff(abs(det)>eps)); false]);
      
      % fill up with some new dummy lines
      l = 1; dx = sqrt(numel(xy)/2)*dy/2;      
      
      nto = fix(sqrt(sum(diff(pxy).^2,2))/ dx);
      cs = cumsum([1; 1 + nto]);
      
      ptxy(cs,: ) = pxy;
      for lk=1:length(nto);
        a = pxy(lk,:)';
        b = pxy(lk+1,:)';
        ab = a-b;
        for llk = cs(lk)+1:cs(lk+1)-1
          ptxy(llk,:) = a-(llk-cs(lk)).*ab./(nto(lk)+1);          
        end
      end
      pxy = ptxy;
      
      dummy = [];
      for l=1:size(pxy,1)-1
        
        a = pxy(l,:)';
        b = pxy(l+1,:)';
        ab = a-b;
        nab = ab./norm(ab);
        
        H = -(I-2/(ab'*ab)*(ab*ab'));  %mirrow
        
        shiftab = R( atan2(ab(2),ab(1)) ) * dxy;
                
        hxy = [x-a(1)-shiftab(1) y-a(2)-shiftab(2)]*H;
        hxy = [hxy(:,1)+a(1)+shiftab(1) hxy(:,2)+a(2)+shiftab(2)];
        
        d = sqrt(sum((hxy-xy).^2,2));
       
        lk = 2; cont = true;
        dab = sqrt(sum(ab.^2));
        df = 2*dy*sign(ab);
        while cont && lk < 250
          
          tmpxy = hxy(d < lk*dy,:);
          tx = tmpxy(:,1);
          ty = tmpxy(:,2);
          
          cc1 =  (tx-(a(1)+ df(1))).*nab(1)+ (ty-(a(2)+df(2))).*nab(2) ;
          cc2 =  (tx-(b(1)- df(1))).*nab(1)+ (ty-(b(2)-df(2))).*nab(2) ;
           
          ind = cc1 > 0 | cc2 < 0;
          tmpxy = tmpxy(~ind,:);
          
          cont = dab./size(tmpxy,1) > dy/3;
          if lk < 50, lk = lk*2;
          else lk = lk+10; end
        end
        
        dummy = [dummy; tmpxy];
        
      end
      
      dummy = unique(dummy,'first','rows');
      
    case {'cubi','cubei'} %grid reconstruction, TODO
      hx = unique(xy(:,1));
      hy = unique(xy(:,2));    

      [xx1 yy1] = meshgrid(hx,hy);

      x = [ hx(1:2)-2*diff(hx(1:3)); hx(:); hx(end-1:end)+2*diff(hx(end-2:end))];
      y = [ hy(1:2)-2*diff(hy(1:3)); hy(:); hy(end-1:end)+2*diff(hy(end-2:end))];
        clear hx hy

      [xx2 yy2] = meshgrid(x,y);

      clear x y
      ff1 = [xy(:,1),xy(:,2)];
      ff2 = [xx2(:),yy2(:)];
        clear xx1 xx2 yy1 yy2

      m = ismember(ff2,ff1,'rows');

      dummy = ff2(~m,:);    
        clear ff1 ff2 m
    case 'sphere'
      dx = (max(xy(:,1)) - min(xy(:,1)))/1.25;
      dy = (max(xy(:,2)) - min(xy(:,2)))/1.25;

      cc = -pi:.05:pi;
      hx = cos(cc);
      hy = -sin(cc);

      hx = (hx)*dx+ (max(xy(:,1)) + min(xy(:,1)))/2;
      hy = (hy)*dy+ (max(xy(:,2)) + min(xy(:,2)))/2;

      dummy = unique([hx(:),hy(:)],'first','rows');

        clear dx dy hx hy cc 
    otherwise
      error('wrong augmentation option')
  end
  xy = [xy; dummy];
%%  voronoi decomposition
  [v c] = voronoin(xy,{'Q7','Q8','Q5','Q3','Qz'});   %Qf {'Qf'} ,{'Q7'}
  
  c(end-length(dummy)+1:end) = [];
  
  if check_option(varargin,'plot')
    cl = cellfun('prodofsize',c);
    rind = splitdata(cl,3);
    for k=1:numel(rind)
      tind = rind{k};
      faces = NaN(length(tind),max(cl(tind)));
      for l = 1:length(tind)
        faces(l,1:cl(tind(l))) = c{tind(l)};
      end
      fc{k} = faces;
    end
    c = fc;
  end
  
end



function [xy, ndx, pos] = uniquepoint(xy,eps)

txy = fix(xy/eps);

% 
[txy ndx]= sortrows(txy);

ind = [true ; any(diff(txy),2)];

pos = cumsum(ind);
pos(ndx) = pos;
% 
xy = xy(ndx(ind),:);


function dxy = estimateGridResolution(x,y)

rndsmp = [ (1:sum(1:length(x)<=100))'; unique(fix(1+rand(200,1)*(length(x)-1)))];

xx = repmat(x(rndsmp),1,length(rndsmp));
yy = repmat(y(rndsmp),1,length(rndsmp));
dist = abs(sqrt((xx-xx').^2 + (yy-yy').^2));
dxy = min(dist(dist>eps)); 


