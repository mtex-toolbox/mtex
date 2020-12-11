function display(rot,varargin)
% standart output

displayClass(rot,inputname(1),varargin{:});
if length(rot)~=1, disp(['  size: ' size2str(rot)]); end

if length(rot) < 20 && ~isempty(rot)
  
  Euler(rot);
  
else
  disp(' ')
end


