function [v c rind] = spatialdecomposition(xy,varargin)

if check_option(varargin,'unitcell') || ~check_option(varargin,'voronoi')
  
  unitcell = @(s,d,rot) exp(1i*(pi/s+rot:pi/(s/2):2*pi+rot))*1./sqrt((s/2))*d;

  %% estimate grid resolution

  dxy = get_option(varargin,'GridResolution',[]);

  x = xy(:,1);
  y = xy(:,2);
  
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

        area = @(x,y) abs(0.5.*sum(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)));
        area = cellfun(@(c1) area(v([c1 c1(1)],1),v([c1 c1(1)],2)),c);

        [a ci] = min(area);

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
  
  if ~check_option(varargin,'faces')
    ct = cell(length(x),1);
    for k=1:length(c)
      ct{k} = c(k,:);
    end 
    c = ct;
  else
    rind = [];
  end
else
  augmentation = get_option(varargin,'augmentation','cube');
  
  % extrapolate dummy coordinates %dirty
  switch lower(augmentation)
    case 'cube'
      x = xy(:,1);
      y = xy(:,2);
      k = convhull(x,y);
      
      
      
%       plot(xy(:,1),xy(:,2),'.')
%       hold on,
%       plot(xy(k,1),xy(k,2),'.-')
      
      rndsmp = [ (1:sum(1:length(x)<=100))'; unique(fix(1+rand(200,1)*(length(x)-1)))];

      xx = repmat(x(rndsmp),1,length(rndsmp));
      yy = repmat(y(rndsmp),1,length(rndsmp));
      dxy = abs(sqrt((xx-xx').^2 + (yy-yy').^2));
      
      dxy = sort(dxy);
      dxy = dxy(1:6<end,:);
      dxy = max(min( mean(dxy(2:end,:),1) ),10^-4);
%        dxy = 0.1; %min(dxy(dxy>eps))

      dummy = [];
      for ll = 1:length(k)-1
        xx = x([k(ll) k(ll+1)]);
        yy = y([k(ll) k(ll+1)]);

        dx = diff(xx);  dy = diff(yy);

        rot = angle(complex(dx,dy));    
        shiftxy = [cos(rot) -sin(rot); sin(rot) cos(rot)] * [0 ; dxy]./2;

%         hold on
%         plot(xx-shiftxy(1),yy-shiftxy(2),'r-')
        
        
        l1 = [ dx dy ];
        l1 = repmat(l1./norm(l1),length(xy),1);
        l2 = repmat([xx(1) yy(1)] - shiftxy' ,length(xy),1);

        l3 =  [ -dy dx ];
        l3 =  repmat(l3./norm(l3),length(xy),1);
        dist = dot(xy - l2,l3,2);

        co = l2 + repmat( dot(xy - l2,l1,2) ,1,2).*l1;

        [co ia]= sortrows(co);
        dist = dist(ia);      

        if sign(dx) < 0 , pmx = @ge; else pmx = @le; end
        if sign(dy) < 0 , pmy = @ge; else pmy = @le;  end

        idxy = (pmx(co(:,1) - xx(1),dx) & pmx(xx(2) - co(:,1),dx)) | ...
               (pmy(co(:,2) - yy(1),dy) & pmy(yy(2) - co(:,2),dy));
        co = co(idxy , : );
        dist = dist(idxy);

        sel = false(size(dist));     
        fdist = dxy*10; iter = 1;   

        while max(fdist) - dxy > 10^-10 
          sel = sel | dist < dxy*iter;

          fdist = abs(sqrt(sum(diff(co(sel,:)).^2,2)));
          iter = iter+1;

          if all(sel), break, end;
        end

        co = co(sel,:);  
        if size(co,1) > 2
          non = [true;any(diff(co)> dxy*10^-8 ,2) ];
          co = co(non,:);
        end

        dummy = [dummy ;co];
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
%   plot(dummy(:,1),dummy(:,2),'r.')
  
  xy = [xy; dummy];
%%  voronoi decomposition
  [v c] = voronoin(xy,{'Q7','Q8','Q5','Q3','Qz'});   %Qf {'Qf'} ,{'Q7'}
  
  c(end-length(dummy)+1:end) = [];
  
%   vv = cellfun(@(x) [v(x,:); v(x(1),:); NaN NaN] , c,'uniformoutput',false);
%   vv = vertcat(vv{:});
%   plot(vv(:,1),vv(:,2),'r-')
  
  
  if check_option(varargin,'faces')
    cl = cellfun('prodofsize',c);
    [cl ndx] = sort(cl,'descend');
    c = c(ndx);
    idf = 1:numel(c);
    idf = idf(ndx);    
    
    ind = splitdata(cl,3);
    fc = cell(size(ind));
    rind = cell(size(ind));
    for k=1:numel(ind)
      tind = ind{k};
      tfaces = NaN(length(tind),max(cl(tind)));
      for l = 1:length(tind)
        tfaces(l,1:cl(tind(l))) = c{tind(l)};
      end
      fc{k} = tfaces;
      rind{k} = idf(tind);
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

