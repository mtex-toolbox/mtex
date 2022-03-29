function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>function handle component</strong>');
else
  displayClass(SO3F,inputname(1),varargin{:});
end

if length(SO3F) > 1, disp([' size: ' size2str(SO3F)]); end
%disp([' fun: ' char(SO3F.fun)]);

disp(' ')

end
