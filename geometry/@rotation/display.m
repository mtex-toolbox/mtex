function display(rot,varargin)
% standart output

displayClass(rot,inputname(1),varargin{:});
disp(['  size: ' size2str(rot)]);

if length(rot) < 20 && ~isempty(rot)
  
  Euler(rot);
  
else
  disp(' ')
end


