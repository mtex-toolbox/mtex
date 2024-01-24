function display(SO3VF,varargin)
% standard output
displayClass(SO3VF,inputname(1),[],'moreInfo',symChar(SO3VF),varargin{:});
if check_option(SO3VF.tangentSpace,'right')
  disp(['  tangent space: ' , SO3VF.tangentSpace]);
end
disp(' ')

end
