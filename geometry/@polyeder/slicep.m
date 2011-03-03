function [inp ofx] = slicep(p,sp,varargin)
%
%% Input
%  p  - @polyeder
%  sp - slicing plane
%
%%
%

x0 = sp.Vertices(1,:);
n = facenormal(sp.Vertices);

if isa(p,'grain') && check_option(varargin,'subfractions')
  sub = get(p,'subfractions');
  p = [sub.P];
end

p = polyeder(p);
of = [];
in = false(size(p));
for k=1:numel(p)
  v = calcslice(p(k),n,x0);
  of = [of ;v];
  
  in(k) = ~isempty(v);
end



if nargout > 0
  inp = in;
  ofx = of;
else
  h = line(of(:,1),of(:,2),of(:,3));
  optiondraw(h,varargin{:});
end

fixMTEXplot

function of = calcslice(p,n,x0)


M = p.Faces;
M(:,end+1) = M(:,1);
X = p.Vertices;

sz = size(M);
Xr  = reshape(X(M,:), [sz,3] );

% dist of each point to plane
Xrf(:,:,1) = Xr(:,:,1) - x0(1);
Xrf(:,:,2) = Xr(:,:,2) - x0(2);
Xrf(:,:,3) = Xr(:,:,3) - x0(3);

dist = n(1) * Xrf(:,:,1) + n(2) * Xrf(:,:,2) + n(3) * Xrf(:,:,3);

isntrs = any(dist < 0,2) & any(dist > 0,2);


% patch('vertices',X,'faces',M(isntrs,:),'facecolor',[0.9 0.5 0.5])

if any(isntrs)
  sec1 = diff(sign(dist(isntrs,:)),1,2)~=0;
  sec2(:,2:sz(2)) = sec1;
  sec1(:,sz(2)) = 0;

  Xr = Xr(isntrs,:,:);
  dist = dist(isntrs,:);
  M = M(isntrs,:);

  Xrx = Xr(:,:,1)';
  Xry = Xr(:,:,2)';
  Xrz = Xr(:,:,3)';

  ax = Xrx(sec1'); bx = ax - Xrx(sec2');
  ay = Xry(sec1'); by = ay - Xry(sec2');
  az = Xrz(sec1'); bz = az - Xrz(sec2');

  dist = dist';
  pp = dist(sec1')./(dist(sec1')-dist(sec2'));
  
  ax = ax - pp.*bx;
  ay = ay - pp.*by;
  az = az - pp.*bz;

  Mt = M';
  Mt1 = Mt(sec1');
  Mt1 = reshape(Mt1,2,[]);
  Mt2 = Mt(sec2');
  Mt2 = reshape(Mt2,2,[]);
  
  pseudoid = [Mt1(1,:).*Mt2(1,:); Mt1(2,:).*Mt2(2,:)];
 
  [a b m] = unique(pseudoid);
  
  m = reshape(m,2,[]);
  
  ax =  ax(b);
  ay =  ay(b);
  az =  az(b);
  
  f = m(:,1);
  m(:,1) = -1;
  of = [];
  while true
    
    [l r] = find(f(end) == m);
    
    if ~isempty(l)
      l = l(end);
      r = r(end);      
      f(end+1) = m( mod(l,2)+1,r );
      m(:,r) = -1;
      
    else
      
      
      of = [of; ax(f),ay(f),az(f); NaN NaN NaN];
%         line(ax(f),ay(f),az(f),'color','y','linewidth',1)
       
      b = find(m(1,:) > 0,1,'first');
      
      if ~isempty(b)
        f = m(:,b);
        m(:,b) = -1;        
      else  
%         of = [ax(f),ay(f),az(f)];
        break
      end
    end
    
  end
else
  of = [];
end

function n = facenormal(X)

a = X(1,:)-X(2,:);
b = X(2,:)-X(3,:);

n = [a(2).*b(3)-a(3).*b(2)
     a(3).*b(1)-a(1).*b(3)
     a(1).*b(2)-a(2).*b(1)];
% n = cross(n(1,:),n(2,:));
n = n./sqrt(sum(n.^2));






function [xyz, ndx, pos] = uniquepoint(x,y,z,eps)

ndx = 1:int32(numel(x));
[ig,ind] = sort(x);
clear ig
ndx = ndx(ind);
clear ind
[ig,ind] = sort(y(ndx));
clear ig
ndx = ndx(ind);
clear ind
[ig,ind] = sort(z(ndx));
clear ig
ndx = ndx(ind);
clear ind

%     
ind = [true; abs(diff(x(ndx))) > eps | abs(diff(y(ndx))) > eps | abs(diff(z(ndx))) > eps];
% 
pos = cumsum(ind);
pos(ndx) = pos;
ind = ndx(ind);
xyz = [x(ind,:) y(ind,:) z(ind,:)];





function border = convert2border(gl,gr)

[gll a] = sort(gl);
[grr b] = sort(gr);
    
nn = numel(gl);
    
sb = zeros(nn,1);
v = sb;
    
sb(b) = a;    
v(1) = a(1);
    
cc = 0;
l = 2;
lp = 1;
    
while true
  np = sb(v(lp));
      
  if np > 0
    v(l) = np;
    sb(v(lp)) = -1;
  else
    cc(end+1) = lp;
    n = sb(sb>0);
    if isempty(n)
      break
    else
      v(l) = n(1);
    end
  end  
      
  lp = l;
  l=l+1;      
end

nc = numel(cc)-1; 
if nc > 1, 
  border = cell(1,nc);
  for k=1:nc
    border(k) = {gl(v(cc(k)+1:cc(k+1)))};
  end  
else
  border = gl(v(cc(1)+1:cc(2)));
end

