function display(q,varargin)
% standart output

if check_option(varargin,'onlyShowQuaternions')
  d = [q.a(:),q.b(:),q.c(:),q.d(:)];
  d(abs(d)<1e-13) = 0;
  cprintf(d,'-L','  ','-Lc',{'a' 'b' 'c' 'd'});
  return
end

displayClass(q,inputname(1));

if length(q)~=1, disp(['  size: ' size2str(q)]); end

if length(q) < 20 && ~isempty(q)
  
  display(q,'onlyShowQuaternions')
  
elseif ~getMTEXpref('generatingHelpMode') && ~isempty(q)

  disp(' ')
  s = setappdata(0,'data2beDisplayed',q);
  disp(['  <a href="matlab:display(getappdata(0,''',s,'''),''onlyShowQuaternions'')">show quaternions</a>'])
  disp(' ')

end
