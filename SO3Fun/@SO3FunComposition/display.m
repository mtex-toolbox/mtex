function display(SO3F,varargin)
% standard output

displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});  

% display symmtries and minerals
if SO3F.antipodal, disp('  antipodal: true'); end

% display components
disp(' ');
for i = 1:length(SO3F.components)
  SO3F.components{i}.display('skipHeader');
end
