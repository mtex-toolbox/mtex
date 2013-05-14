function pf = delete(pf,id)
% eliminates points from pole figures
%
% A new set of pole figures is constrcuted from the initial pole figures by
% skipping the points specified by their index id
%
%% Syntax  
% pf  = delete(pf,id)
%
%% Input
%  pf   - @PoleFigure
%  id   - index set 
%
%% Output
%  pf - @PoleFigure
%
%% See also
% PoleFigure/get PoleFigure_index

if isnumeric(id),
  inds = false(sum(GridLength(pf)),1);
  inds(id) = true;
  id = inds;
end

cs = cumsum([0,GridLength(pf)]);

for k = 1:length(pf)
  idi = id(cs(k)+1:cs(k+1));
  
  if ~isempty(pf(k).bgdata), pf(k).bgdata(idi) = [];end
  pf(k).data(idi) = [];
  pf(k).r = delete(pf(k).r,idi);
end
