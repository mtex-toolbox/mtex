function autofit(s)
% switches the autofitting feature of multiple figures on / off

if ~isappdata(gcf,'autofit'), return;end

if nargin
  setappdata(gcf,'autofit',s);
elseif strcmp(getappdata(gcf,'autofit'),'on')
  setappdata(gcf,'autofit','off');
  disp('autofit off')
else
  setappdata(gcf,'autofit','on');
  disp('autofit on')
end
