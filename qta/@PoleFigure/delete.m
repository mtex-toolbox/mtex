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
% PoleFigure/getdata PoleFigure/getbg PoleFigure/getr PoleFigure_index

if isa(id,'logical'), id = find(id);end
cs = cumsum([0,GridLength(pf)]);

for i= 1:length(pf)
	
	idi = id((id > cs(i)) & (id<=cs(i+1)));
  if ~isempty(pf(i).bgdata), pf(i).bgdata(idi-cs(i)) = [];end
	pf(i).data(idi-cs(i)) = [];
	pf(i).r = delete(pf(i).r,idi-cs(i));
end
