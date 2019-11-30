function display(SO3F,varargin)
% standard output

displayClass(SO3F,inputname(1),varargin{:});

if length(SO3F) > 1, disp([' size: ' size2str(SO3F)]); end
disp([' bandwidth: ' num2str(SO3F.bandwidth)]);

end
