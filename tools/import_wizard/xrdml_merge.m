function p_correted = xrdml_merge(pfs)
% returns correction of xrmdl raw data
%
%% Syntax  
% pfn  = delete(pf,id)
%
%% Input
%  pfs   - list of @PoleFigure , raw-pf, background, defocusing, defocusing
%  background
%
%% Output
%  p_correted - @PoleFigure
%

epsilon = 1e-9;

for i=2:4
  theta = getTheta(getr(pfs(i)));
  for k=1:GridLength(getr(pfs(i)))
    id = find(getTheta(getr(pfs(1))) >= theta(k)-epsilon &...
      getTheta(getr(pfs(1))) <= theta(k)+epsilon);
    d(id) = getdata(pfs(i),k);
  end  
  p(i) = PoleFigure(getMiller(pfs(i)),...
    getr(pfs(1)),d,...
    getCS(pfs(i)),getSS(pfs(i)));
end

%correction
p_correted = (pfs(1)-p(2))/(p(3)-p(4)); 