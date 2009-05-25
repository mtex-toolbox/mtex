function [J T q p] = joincount(grains,coloring,varargin)
% returns the a joins-count between neighbour coloring
%
%% Input
%  grains   - @grain
%  coloring - list corresponding to grains with its color
%
%% Output
% J   - join count matrice
% T   - normalized chi^2 test of independence
% q   - empirical entities actually counted
% p   - esitmated
%
%% Options
% WEIGHTED/PERIMETER  - use perimeter as weight.
% AREA                - use area as weight.
%
%% Example
% [J Jt q p] = joincount(grains,hassubfractions(grains))
%

nc = length(grains);

[colors m n] = unique(coloring(:));
J = zeros(size(colors,1));
if check_option(varargin,{'weighted','perimeter'})
  w = perimeter(grains);
elseif check_option(varargin,'area')
  w = area(grains);
else
  w = ones(nc,1);
end

for k=1:nc
  kn = grains(k).neighbour; %carefull with deleted neighbours
  kn = kn(grains(k).id ~= grains(k).neighbour); % without selfreference

  J(n(k),n(kn)) =    J(n(k),n(kn)) + w(kn)';
  J(n(kn),n(k)) =    J(n(kn),n(k)) + w(kn); 
end

J = J./2;
Js = triu(J);
Js = sum(Js(:));
% 
q = (J./Js);


[a ndx] = sort(n);
wt = w(ndx);
pa = histc(n, n(m));
wc = mat2cell(wt,pa);
%
p = diag(cellfun(@(x) sum(x) ,wc)./sum(w));

%%

nc = size(J,1);
pi = zeros(nc,nc);
for i=1:nc  
  for j=1:nc-1
    pi(i,i) = pi(i,i) + 0.5* ( q(i,j) +  q(j+1,i) );
  end
  pi(i,i) = pi(i,i) + q(i,i);
end
q = triu(q);

%% indipendence test


Pb = zeros(nc,nc);

for k=1:nc
  for l=1:nc
    if k ~=l
      Pb(k,l) = (2*J(k,k)+J(k,l)) ./ (2*(J(k,k)+J(k,l)+J(l,l)));     
    end    
  end
end

T = zeros(nc,nc);
for k=1:nc
  for l=1:nc
    if k<l      
      tJ = (J(k,k)+J(k,l)+J(l,l));   
      
      mJbb = tJ * Pb(k,l)^2;
      mJbw = tJ * Pb(k,l) * Pb(l,k);
      mJww = tJ * Pb(l,k)^2;     
          
      T(k,l) = (J(k,k)-mJbb).^2/mJbb + ...
               (J(k,l)-mJbw).^2/mJbw + ...
               (J(l,l)-mJww).^2/mJww;
      T(k,l) = T(k,l)./tJ;
    end
  end
end





%% TODO



