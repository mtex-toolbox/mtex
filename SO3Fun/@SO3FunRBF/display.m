function display(SO3F,varargin)
% called by standard output

if ~check_option(varargin,'skipHeader')
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
  if SO3F.antipodal, disp('  antipodal: true'); end
  disp(' ');
end

if SO3F.c0 > 0
  disp('  <strong>uniform component</strong>');
  if SO3F.c0 > 0, disp(['  weight: ',xnum2str(SO3F.c0)]); end
  
  disp(' ');
end
  
if ~isempty(SO3F.center)
  
  if length(SO3F.center)==1
    disp('  <strong>unimodal component</strong>');
  else
    disp('  <strong>multimodal components</strong>');
  end
  disp(['  kernel: ',char(SO3F.psi)]);
  if isa(SO3F.center,'SO3Grid')
    disp(['  center: ',char(SO3F.center)]);
    disp(['  weight: ',xnum2str(sum(SO3F.weights(:)))]);
    disp(' ');
  else
    disp(['  center: ',num2str(length(SO3F.center)) ' orientations']);
    s.weight = SO3F.weights; 
    Euler(SO3F.center,s)
  end
end

end
