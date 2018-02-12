function [interface,options] = check_interfaces(fname,type,varargin)
% determine interface from file

if ~exist(fname,'file'), error('File %s not found.',fname);end

% find all installed interfaces
interfaces = dir([mtex_path '/interfaces/load' type '_*.m']);
interfaces = {interfaces.name};
% do not use interfaces generic
ind = cellfun('isempty',strfind(interfaces,'generic'));
interfaces = interfaces(ind);

interface = {}; options = varargin;

% ckeck for matching interfaces
w = warning;
warning off all
for i =1:length(interfaces)
  try
    n = nargout(interfaces{i}(1:end-2)); %#ok<NASGU>
    %[args{1:(2*(n>1))}] = feval(interfaces{i}(1:end-2),fname,varargin{:},'check');    
    eval(['[args{1:(2*(n>1))}] = ' interfaces{i}(1:end-2) '( fname,varargin{:},''check'');']);
    
    if numel(args) > 1, options = args{2};end
    
    interfaceName = regexp(interfaces{i},'_(.*).m','tokens');
    interface = [interface(:)',{char(interfaceName{1})}];
  catch
  end
end
warning(w);

% more then one interface
if iscell(interface) && length(interface)>=2  % if there are multiple interfaces
  i = listdlg('PromptString',...
    'There is more then one interface matching your data. Select one!',...
    'SelectionMode','single',...
    'ListSize',[400 100],...
    'ListString',interface);
  interface = interface(i);
end

% no interface - try generic interface
if isempty(interface)
  
  try
    [d,options] = feval(['load' type '_generic'],fname,'check',varargin{:});
  catch %#ok<CTCH>
    %disp('The error was:')
    %disp(' ');
    %disp(lasterr); %#ok<LERR>
    %disp(' ');
    error('Could not detect file format. You may ask for help in the MTEX forum (https://groups.google.com/forum/#!forum/mtexmail).');
  end
  
  if isempty(d)
    interface = '';
  else
    interface = 'generic';
  end
  
end

interface = char(interface);
