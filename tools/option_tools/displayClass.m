function displayClass(obj,vName,varargin)

if check_option(varargin,'skipHeader'), return; end

disp(' ');

vName = get_option(varargin,'variableName',vName);
className = class(obj);
altName = get_option(varargin,'className',className);
scopes = get_option(varargin,'moreInfo');

str = [vName ' = ' doclink([className '.' className],altName)];
%str = [vName ' = <strong>' altName '</strong>'];

if ~isempty(scopes), str = [str,' (',scopes,')']; end

disp(str);

end