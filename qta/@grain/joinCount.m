function [J T q p] = joincount(grains,coloring,varargin)
% returns the a joins-count between neighbour coloring
%
%% Input
%  grains   - @grain
%  coloring - list corresponding to grains with its color
%
%% Output
%  J - join count matrice
%  T - normalized chi^2 test of independence
%  q - empirical entities actually counted
%  p - esitmated
%
%% Example
% [J Jt q p] = joincount(grains,get(grains,'phase'))
%


pair = pairs(grains);
pair(pair(:,1) == pair(:,2),:) = []; % delete self reference

[c m color] = unique(coloring);
colors =  color(pair);


J = full(sparse(colors(:,1),colors(:,2),1))./2;
 
q = ( J ./ sum(sum(triu(J))) );

w = numel(color);
p = zeros(size(J));
for k=1:length(c)
  p(k,k) = sum(k == color)./w;
end


%%

nc = size(J,1);
pi = zeros(size(J));
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
    if k ~= l
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



