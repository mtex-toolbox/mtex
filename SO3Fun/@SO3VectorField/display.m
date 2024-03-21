function display(SO3VF,varargin)
% standard output
displayClass(SO3VF,inputname(1),[],'moreInfo',symChar(SO3VF),varargin{:});

disp(['  tangent space: ' , char(SO3VF.tangentSpace)]);

disp(' ')

end
