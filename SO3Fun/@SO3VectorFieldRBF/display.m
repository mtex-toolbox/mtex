function display(SO3VF,varargin)
% standard output

displayClass(SO3VF,inputname(1),[],'moreInfo',symChar(SO3VF),varargin{:});

% RBF-structure
disp(['  kernel: ',char(SO3VF.SO3F.psi)]);
if isa(SO3VF.SO3F.center,'SO3Grid')
  disp(['  center: ',char(SO3VF.SO3F.center)]);
else
  disp(['  center: ',num2str(length(SO3VF.SO3F.center)), ' orientations']);
end

% Tangent space
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
