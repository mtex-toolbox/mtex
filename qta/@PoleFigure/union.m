function pf = union(pf1,pf2)
% crytsallographic direction to one
%% Syntax
%  pf = union(pf1,pf2)
%
%% Input
%  pf1 - @PoleFigure
%  pf2 - @PoleFigure (optional)
%
%% Output
%  pf  - @PoleFigure

if nargin==2, pf1 = [pf1,pf2];end

pf(1) = pf1(1);

for i = 2:length(pf1)
  
  for j = 1:length(pf)    
    if all(pf(j).h == pf1(i).h), break;end
  end
    
  if all(pf(j).h == pf1(i).h)
    pf(j).r = [pf(j).r,pf1(i).r]; %#ok<AGROW>
    pf(j).data = [reshape(pf(j).data,1,[]),reshape(pf1(i).data,1,[])]; %#ok<AGROW>
  else
    pf(length(pf)+1) = pf1(i); %#ok<AGROW>
  end
end
