function display(SO3VF,varargin)
% standard output
displayClass(SO3VF,inputname(1),[],'moreInfo',symChar(SO3VF),varargin{:});

% tangent space
disp(['  tangent space: ' , char(SO3VF.tangentSpace)]);

% hidden properties
if SO3VF.CS~=SO3VF.hiddenCS || SO3VF.SS ~= SO3VF.hiddenSS
  disp( ['  intern symmetries: ' char(SO3VF.hiddenCS,'compact') ' ' char(8594) ' ' char(SO3VF.hiddenSS,'compact')] );
end
if SO3VF.tangentSpace ~= SO3VF.internTangentSpace
  disp( ['  intern tangent space: ' char(SO3VF.internTangentSpace)] );
end

disp(' ')

end
