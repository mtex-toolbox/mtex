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
%   ori - @orientation
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
  elseif check_option(varargin,'LaTex')
    n1 = [char(hkl,'LaTex'),char(uvw,'LaTex')];
    n1 = strrep(n1,'$$','');
  else
    n1 = hkl;
    n2 = uvw;
  end
  
  return  
end


% maybe more then one orientation should be transformed
if length(mori) > 1
  n1 = Miller.nan(size(mori),mori.CS);
  n2 = Miller.nan(size(mori),mori.SS);
  d1 = Miller.nan(size(mori),mori.CS,'uvw');
  d2 = Miller.nan(size(mori),mori.SS,'uvw');
  for i = 1:length(mori)
    [n1(i),n2(i),d1(i),d2(i)] = round2Miller(mori.subSet(i),varargin{:});
  end
  
  if nargout == 0, showResult; end
  return
end

penalty = get_option(varargin,'penalty',0.002);

maxIndex = get_option(varargin,{'maxIndex','maxHKL'},4);

% all plane normales
[h,k,l] =meshgrid(0:maxIndex,-maxIndex:maxIndex,-maxIndex:maxIndex);
n1 = Miller(h(:),k(:),l(:),mori.CS);
n2 = reshape(mori * n1,[],1);
rh2 = round(n2);
hkl2 = rh2.hkl;

% fit of planes
omega_h = angle(rh2(:),n2(:)) + ...
  (h(:).^2 + k(:).^2 + l(:).^2 + sum(hkl2.^2,2)) * penalty;

% all directions
[u,v,w] = meshgrid(0:maxIndex,-maxIndex:maxIndex,-maxIndex:maxIndex);
d1 = Miller(u(:),v(:),w(:),mori.CS,'uvw');
d2 = reshape(mori * d1,[],1);
rd2 = round(d2);
uvw2 = rd2.uvw;

% fit of directions
omega_d = angle(rd2(:),d2(:)) + ...
  (u(:).^2 + v(:).^2 + w(:).^2 + sum(uvw2.^2,2)) * penalty;

% directions should be orthognal to normals
fit = bsxfun(@plus,omega_h(:),omega_d(:).') + 10*(abs(pi/2-angle_outer(n1,d1,'noSymmetry')));

[~,ind] = nanmin(fit(:));
[ih,id] = ind2sub(size(fit),ind);

n1 = n1(ih);
d1 = d1(id);
n2 = round(mori * n1);
d2 = round(mori * d1);

% switch to UVTW for trigonal and hexagonal materials
if d1.lattice.isTriHex, d1.dispStyle = 'UVTW'; end
if d2.lattice.isTriHex, d2.dispStyle = 'UVTW'; end

if nargout == 0, showResult; end

function showResult
    
  mori_exact = orientation.map(n1,n2,d1,d2);
  err = angle(mori,mori_exact);
  disp(' ');
  for k = 1:length(n1)
    disp([char(n1(k)) ' || ' char(n2(k)) '   ' char(d1(k)) ' || ' char(d2(k)) ...
      '   error: ',xnum2str(err(k)./degree),mtexdegchar']);
  end
  disp(' ');  
  
  clear n1 s1 n2 d2
    
end

end



% mori = orientation.map(Miller(1,1,-2,0,CS),Miller(2,-1,-1,0,CS),Miller(-1,0,1,1,CS),Miller(1,0,-1,1,CS)) * orientation('axis',vector3d.rand(1),'angle',1*degree,CS,CS)
% 
