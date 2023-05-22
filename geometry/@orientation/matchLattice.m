function [n1,n2,d1,d2] = matchLattice(mori,varargin)
% find lattice alignements for arbitrary misorientations
%
% Description
%
% Given a misorientation mori find all face normals n1, n2 and crystal
% directions d1, d2, such that mori * n1 = n2 and mori * d1 = d2.
%
% Syntax
%
%   matchLattice(mori)
%
%   [n1,n2,d1,d2] = matchLattice(mori)
%   [n1,n2,d1,d2] = matchLattice(mori,'threshold',1*degree)
%   [n1,n2,d1,d2] = matchLattice(mori,'maxIndex',3)
%
% Input
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
% round2Miller

delta = get_option(varargin,'threshold',1*degree);

maxIndex = get_option(varargin,{'maxIndex','maxHKL'},3);

% all plane normales
hkl = allHKL(maxIndex);

n1 = Miller(hkl(:,1),hkl(:,2),hkl(:,3),mori.CS);
morin1 = reshape(mori * n1,[],1);
n2 = round(morin1,'maxHKL',maxIndex);

% fit of planes
fit = angle(n2,morin1);

n1 = n1(fit<=delta);
n2 = n2(fit<=delta);
fit = fit(fit<=delta);

[fit, order] = sort(fit);
n1 = n1(order);
n2 = n2(order);

if nargout == 0

  disp(' ')
  n1Char = char(n1,'cell'); ln1 = max(cellfun(@length,n1Char));
  n2Char = char(n2,'cell'); ln2 = max(cellfun(@length,n2Char)); 

  ln1 = 1 + max( ln1,length(n1.CS.mineral));
  ln2 = max( ln2,length(n2.CS.mineral));

  disp([fillStr(n1.CS.mineral,ln1,'left') '    ' ...
    fillStr(n2.CS.mineral,ln2,'right') ...
     '  fit']);
  
  for kk = 1:length(n1)
    disp([fillStr(n1Char{kk},ln1,'left') ' || ' fillStr(n2Char{kk},ln2) ...
      '  ',xnum2str(fit(kk)./degree,'precision',0.1),mtexdegchar']);
  end
end

% all directions
uvw = allHKL(maxIndex);

d1 = Miller(uvw(:,1),uvw(:,2),uvw(:,3),mori.CS,'uvw');
morid1 = reshape(mori * d1,[],1);
d2 = round(morid1,'maxHKL',maxIndex);

% fit of directions
fit = angle(d2,morid1);

d1 = d1(fit<=delta);
d2 = d2(fit<=delta);
fit = fit(fit<=delta);
[fit, order] = sort(fit);
d1 = d1(order);
d2 = d2(order);

% switch to UVTW for trigonal and hexagonal materials
if d1.lattice.isTriHex, d1.dispStyle = 'UVTW'; end
if d2.lattice.isTriHex, d2.dispStyle = 'UVTW'; end

if nargout == 0

  d1Char = char(d1,'cell'); ld1 = max(cellfun(@length,d1Char));
  d2Char = char(d2,'cell'); ld2 = max(cellfun(@length,d2Char)); 

  ld1 = 1 + max( ld1,length(d1.CS.mineral));
  ld2 = max( ld2,length(d2.CS.mineral));

  disp([fillStr(d1.CS.mineral,ld1,'left') '    ' ...
    fillStr(d2.CS.mineral,ld2,'right') ...
     '  fit']);
  
  for kk = 1:length(d1)
    disp([fillStr(d1Char{kk},ld1,'left') ' || ' fillStr(d2Char{kk},ld2) ...
      '  ',xnum2str(fit(kk)./degree,'precision',0.1),mtexdegchar']);
  end

  clear n1 s1 n2 d2

end

end

