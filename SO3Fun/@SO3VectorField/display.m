function display(SO3VF,varargin)
% standard output
displayClass(SO3VF,inputname(1),[],'moreInfo',symChar(SO3VF),varargin{:});

disp(['  tangent space: ' , char(SO3VF.tangentSpace)]);

disp(' ')

disp( [' inner symmetries: ' char(SO3VF.hiddenCS,'compact') ' ' char(8594) ' ' char(SO3VF.hiddenSS,'compact')] );
disp( [' inner tangent space: ' char(SO3VF.internTangentSpace)] );
disp(' ')

end
