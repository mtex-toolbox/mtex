function display(SO3VF,varargin)
% standard output
displayClass(SO3VF,inputname(1),[],'moreInfo',symChar(SO3VF),varargin{:});

disp(['  kernel: ',char(SO3VF.SO3F.psi)]);

if isa(SO3VF.SO3F.center,'SO3Grid')
  disp(['  center: ',char(SO3VF.SO3F.center)]);
else
  disp(['  center: ',num2str(length(SO3VF.SO3F.center)), ' orientations']);
end

disp(['  tangent space: ' , char(SO3VF.tangentSpace)]);

disp(' ')

end
