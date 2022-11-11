function display(SO3VF,varargin)
% standard output
displayClass(SO3VF,inputname(1),[],'moreInfo',symChar(SO3VF),varargin{:});


if SO3VF.SO3F.antipodal, disp('  antipodal: true'); end
if SO3VF.SO3F.isReal, disp('  isReal: true'); end
disp(['  bandwidth: ' num2str(SO3VF.SO3F.bandwidth)]);
disp(['  weights: [' xnum2str(mean(SO3VF.SO3F)) ']']);
disp(' ')

end
