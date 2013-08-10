function pf  = setdata(pf,data,id)
% set polefigure data to a specific value 
%
% Syntax
%   pf  = setdata(pf,data,id)
%
% Input
%  pf   - @PoleFigure
%  data - [double] 
%  id   - index set (optional)
%
% Output
%  pf - @PoleFigure
%
% See also
% PoleFigure/getdata

cs = cumsum([0,GridLength(pf)]);
if nargin == 3
  if isa(id,'logical'), id = find(id);end

  for i= 1:length(pf)  
    idi = id((id > cs(i)) & (id<=cs(i+1)));
    pf(i).intensities(idi-cs(i)) = intensities;
  end
  
else
  
  for i = 1:length(pf)    
    pf(i).intensities = data(min(numel(data),cs(i)+1:cs(i+1)));
  end
  
end


