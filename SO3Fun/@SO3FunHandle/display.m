function display(SO3F,varargin)
% standard output

if check_option(varargin,'skipHeader')
  disp('  <strong>function handle component</strong>');
else
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
  if numel(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end
end

if SO3F.antipodal, disp('  antipodal: true'); end

disp(['  eval: ' char(SO3F.fun)]);

% The computation may be to slow , For example: 
% F = SO3FunHandle(@(rot) calcTaylor(inv(orientation(rot,cs))*eps,sS.symmetrise)
% try
%   m = mean(SO3F,'resolution',5*degree);
%   disp(['  weight: ' xnum2str(m(1))])
% end
disp(' ')

end
