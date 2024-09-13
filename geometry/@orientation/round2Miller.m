function [n1,n2,d1,d2] = round2Miller(mori,varargin)
% find lattice alignements for arbitrary orientations and misorientations
%
% Description
%
% Given an orienation ori find [hkl](uvw) such that ori * [hkl] = Z and ori
% * (uvw) = X.
% 
% Given a misorientation mori find corresponding face normals n1, n2 and
% crystal directions d1, d2, i.e., such that mori * n1 = n2 and mori * d1 =
% d2.
%
% Syntax
%
%   [uvw,hkl] = round2Miller(ori)
%
%   [n1,n2,d1,d2] = round2Miller(mori)
%   [n1,n2,d1,d2] = round2Miller(mori,'penalty',0.01)
%   [n1,n2,d1,d2] = round2Miller(mori,'maxIndex',6)
%
% Input
%  ori  - @orientation
%  mori - mis@orientation
%
% Output
%  uvw,hkl - @Miller
%  n1,n2,d1,d2 - @Miller
%
% Example
%   % revert sigma3 misorientation relationship
%   [n1,n2,d1,d2] = round2Miller(CSL(3,crystalSymmetry('432')))
%
%   % revert back Bain misorientation ship
%   cs_alpha = crystalSymmetry('m-3m', [2.866 2.866 2.866], 'mineral', 'Ferrite');
%   cs_gamma = crystalSymmetry('m-3m', [3.66 3.66 3.66], 'mineral', 'Austenite');
%   mori = orientation.Bain(cs_alpha,cs_gamma)
%   [n_gamma,n_alpha,d_gamma,d_alpha] = round2Miller(mori)
%
% See also
% CSL

if isa(mori.SS,'specimenSymmetry')
  
  hkl = mori \ vector3d.Z;
  hkl = round(hkl,varargin{:});

  uvw = mori \ vector3d.X;
  uvw.dispStyle = MillerConvention(-MillerConvention(uvw.dispStyle)); % direct lattice
  uvw = round(uvw);
     
  if nargout == 0
    
    d = [hkl.coordinates uvw.coordinates];
    d(abs(d) < 1e-10) = 0;
    format = vec2cell(char(uvw.dispStyle));
    format{1} = ['| ' format{1}];
    format = [vec2cell(char(hkl.dispStyle)) format];
    
    cprintf(d,'-L','  ','-Lc',format);
  elseif nargout == 1
    n1 = [char(hkl,varargin{:}),char(uvw,varargin{:})];
    n1 = strrep(n1,'$$','');
  else
    n1 = hkl;
    n2 = uvw;
  end
  
  return  
end

% maybe more then one orientation should be transformed
if length(mori) > 1
  n1 = Miller.nan(size(mori),mori.CS); d1 = n1;
  n2 = Miller.nan(size(mori),mori.SS); d2 = n2;
  d1.dispStyle = MillerConvention(-MillerConvention(n1.dispStyle));
  d2.dispStyle = MillerConvention(-MillerConvention(n2.dispStyle));

  for i = 1:length(mori)
    [n1(i),n2(i),d1(i),d2(i)] = round2Miller(mori.subSet(i),varargin{:});
  end
  
  if nargout == 0, showResult; end
  return
end

penalty = get_option(varargin,'penalty',0.002);
maxIndex = get_option(varargin,{'maxIndex','maxHKL'},4);
nextFit = get_option(varargin,'nextFit',1);

% all plane normales
[h,k,l] = allHKL(maxIndex);
n1 = Miller(h(:),k(:),l(:),mori.CS);
n2 = reshape(mori * n1,[],1);
rn2 = round(n2);
hkl2 = rn2.hkl;

% fit of planes
omega_h = angle(rn2(:),n2(:)) + ...
  (h(:).^2 + k(:).^2 + 0.995*l(:).^2 + ...
  hkl2.^2 * [1;1;0.995] + 0.01*sum(hkl2<-0.1,2)) * penalty;

% all directions
[u,v,w] = allHKL(maxIndex);
if mori.CS.lattice.isTriHex
  d1 = Miller(u(:),v(:),w(:),mori.CS,'UVTW');
else
  d1 = Miller(u(:),v(:),w(:),mori.CS,'uvw');  
end

d2 = reshape(mori * d1,[],1);
if d2.lattice.isTriHex, d2.dispStyle = 'UVTW'; end
rd2 = round(d2);
uvw2 = rd2.uvw;

% fit of directions
omega_d = angle(rd2(:),d2(:)) + ...
  (1.05*(u(:).^2 + v(:).^2 + w(:).^2) + ...
  sum(uvw2.^2,2) + 0.01*sum(uvw2<-0.1,2)) * penalty;

% directions should be orthognal to normals
fit = omega_h(:) + omega_d(:).' + ...
  100*(abs(pi/2-angle_outer(n1,d1,'noSymmetry'))>1e-5)+...
  100*(abs(pi/2-angle_outer(rn2,rd2,'noSymmetry'))>1e-5);

fit_sorted = sort(fit(:));
ind = find(fit(:)==fit_sorted(nextFit));
[ih,id] = ind2sub(size(fit),ind(1));

n1 = n1(ih);
d1 = d1(id);
n2 = rn2(ih);
d2 = rd2(id);

if nargout == 0
  
  showResult; 

elseif nargout == 1
  
  n1 = orientation.map(n1,n2,d1,d2);
  
end

function showResult
    
  mori_exact = orientation.map(n1,n2,d1,d2);
  err = angle(mori,mori_exact);
  disp(' ');
  
  n1 = char(n1,'cell'); ln1 = max(cellfun(@length,n1));
  n2 = char(n2,'cell'); ln2 = max(cellfun(@length,n2));
  d1 = char(d1,'cell'); ld1 = max(cellfun(@length,d1));
  d2 = char(d2,'cell'); ld2 = max(cellfun(@length,n2));

  disp([fillStr('plane parallel',ln1+ln2+4,'left') '   ' ...
    fillStr('direction parallel',ld1+ld2+6) '   fit']);
  for kk = 1:length(n1)
    
    disp([fillStr(n1{kk},ln1,'left') ' || ' fillStr(n2{kk},ln2) '   ' ...
      fillStr(d1{kk},ld1,'left') ' || ' fillStr(d2{kk},ld2) '   ' ...
      '  ',xnum2str(err(kk)./degree,'precision',0.1),mtexdegchar']);
  end

  disp(' ');

  clear n1 s1 n2 d2

end

end



% mori = orientation.map(Miller(1,1,-2,0,CS),Miller(2,-1,-1,0,CS),Miller(-1,0,1,1,CS),Miller(1,0,-1,1,CS)) * orientation('axis',vector3d.rand(1),'angle',1*degree,CS,CS)
% 
