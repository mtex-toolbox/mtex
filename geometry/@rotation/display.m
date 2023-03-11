function display(rot,varargin)
% standart output

displayClass(rot,inputname(1),varargin{:});
if length(rot)~=1, disp(['  size: ' size2str(rot)]); end

if length(rot) <= 19 && ~isempty(rot)
  
  Euler(rot);
  
elseif ~getMTEXpref('generatingHelpMode')  && ~isempty(rot)

  disp(' ')
  s = setappdata(0,'data2beDisplayed',rot);
  disp(['  <a href="matlab:Euler(getappdata(0,''',s,'''))">show Euler angles</a>'])
  disp(' ')

else
  
  disp(' ')

end


