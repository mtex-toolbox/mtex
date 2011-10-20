function d = getdata(pf,id)
% get raw pole figure data
%
%% Syntax
%  d  = getdata(pf,id)
%
%% Input
%  pf - @PoleFigure
%  id - index set (optional)
%
%% Output
%  d - raw diffraction intensities
%
%% See also
% PoleFigure/setdata

cs = cumsum([0,GridLength(pf)]);

if nargin == 1, id = 1:cs(end);end

if isa(id,'logical'), id = find(id);end

d = zeros(length(id),1);
for i= 1:length(pf)
  idi = (id > cs(i)) & (id<=cs(i+1));
  d(idi) = pf(i).data(id(idi)-cs(i));
end
  
