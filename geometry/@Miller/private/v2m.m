function hkl = v2m(m,varargin)
% vector3d --> Miller-indece 
%
%% Syntax
%  v = v2m(m)
%
%% Input
%  v - @vector3d
%
%% Output
%  h,k,l - integer

%% set up matrix
a = get(m.CS,'axis');
V  = dot(a(1),cross(a(2),a(3)));
aa = squeeze(double(cross(a(2),a(3)) ./ V));
bb = squeeze(double(cross(a(3),a(1)) ./ V));
cc = squeeze(double(cross(a(1),a(2)) ./ V));
M = [aa,bb,cc];

%% compute Miller indice
v = reshape(double(m),[],3).';

mv = M \ v;

%% Find common divisor

mbr = selectMaxbyColumn(abs(mv));
mv = mv * diag(1./mbr);

tol = get_option(varargin,'tolerance',1*degree);
maxHKL = get_option(varargin,'maxHKL',9);

hkl = zeros(numel(m),3);
for im = 1:numel(m)

  mm = mv(:,im) * (1:maxHKL);
  rm = round(mm);
  e = sum(mm ./ repmat(sqrt(sum(mm.^2,1)),3,1) .* rm ./ repmat(sqrt(sum(rm.^2,1)),3,1));
    
  e = round(e*1e7);
  [e,j] = sort(e,'descend');
      
  if e(1) > 1e7*cos(tol)
    hkl(im,:) = round(mm(:,j(1)));
  else
    hkl(im,:) = round(mv(:,im)*1000)/1000;
  end

end

if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
  
  hkl = [hkl(:,1:2),-hkl(:,1)-hkl(:,2),hkl(:,3)];
end

