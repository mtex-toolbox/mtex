function [h,k,l] = v2m(m,varargin)
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
a = getaxes(m.CS);
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


for im = 1:numel(m)

  mm = mv(:,im) * (1:20);
  e = sum(abs(mm-round(mm)));
    
  j = find(e<10e-4,1,'first');
    
  if ~isempty(j)
    h(im) = round(mm(1,j));
    k(im) = round(mm(2,j));
    l(im) = round(mm(3,j));
  else
    h(im) = mv(1,im);
    k(im) = mv(2,im);
    l(im) = mv(3,im);
  end

end




