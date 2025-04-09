function display(SO3F,varargin)
% called by standard output

if ~check_option(varargin,'skipHeader')
  displayClass(SO3F,inputname(1),[],'moreInfo',symChar(SO3F),varargin{:});
  if SO3F.antipodal, disp('  antipodal: true'); end
  if numel(SO3F) > 1, disp(['  size: ' size2str(SO3F)]); end
  disp(' ');
end

if any(SO3F.c0 ~= 0)
  disp(strong("  uniform component"));
  if isscalar(SO3F)
    disp(['  weight: ',xnum2str(SO3F.c0)]);
  elseif numel(SO3F)<4
    disp(['  weight: [',xnum2str(SO3F.c0), ']']);
  end
  disp(' ');
end
  
if ~isempty(SO3F.center)
  
  if isscalar(SO3F.center)
    disp(strong("  unimodal component"));
  else
    disp(strong("  multimodal components"));
  end
  disp(['  kernel: ',char(SO3F.psi)]);
  if isa(SO3F.center,'SO3Grid')
    disp(['  center: ',char(SO3F.center)]);
    if isscalar(SO3F)
      out = sum(SO3F.weights);
      % do not display all x-trillion weights
      if length(out) > 5 
          out = [xnum2str(out(1:5)) ' ...']; 
      else
          out = xnum2str(out); 
      end
      disp(['  weight: ',out]);
    elseif length(SO3F)<4 % will actually never be called like this
      disp(['  weight: [', xnum2str(sum(SO3F.weights)), ']']);
    end
    disp(' ');
  else
    disp(['  center: ',num2str(length(SO3F.center)), ' orientations']);
    s.weight = SO3F.weights(:); 
    
    if numel(SO3F.center) < 20 && ~isempty(SO3F.center)
      if isscalar(SO3F)
        Euler(SO3F.center,s)
      else
        Euler(SO3F.center)
      end
    elseif ~getMTEXpref('generatingHelpMode')
      disp(' ')
      a = setAllAppdata(0,'data2beDisplayed',SO3F.center);
      if isscalar(SO3F) && ~issparse(SO3F.weights)
        setAllAppdata(0,'data2beDisplayedWeights',s);
        disp(['  <a href="matlab:Euler(getappdata(0,''',a,'''),getappdata(0,''data2beDisplayedWeights''))">show centers of the components and corresponding weights</a>'])
      else
        disp(['  <a href="matlab:Euler(getappdata(0,''',a,'''))">show centers of the components</a>'])
      end
      disp(' ')
    end
    
  end
end

end
