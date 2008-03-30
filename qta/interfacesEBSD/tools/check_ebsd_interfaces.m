function [interface,options] = check_ebsd_interfaces(fname,varargin)
% determine interface from file

global mtex_path;

if ~exist(fname,'file'), error('File %s not found.',fname{1});end

%% find all installed interfaces
interfaces = dir([mtex_path '/qta/interfacesEBSD/loadEBSD_*.m']);
interfaces = {interfaces.name};
% do not use interfaces txt and generic
ind = cellfun(@isempty,strfind(interfaces,'txt')) & ... 
  cellfun(@isempty,strfind(interfaces,'generic'));
interfaces = interfaces(ind);

interface = {}; options = varargin;

%% ckeck for matching interfaces
w = warning;
warning off all
for i =1:length(interfaces)
  try
    feval(interfaces{i}(1:end-2),fname,varargin{:});
    interface = {interface{:},interfaces{i}(10:end-2)};
  catch  
  end
end
warning(w);

%% more then one interface
if iscell(interface) && length(interface)>=2  % if there are multiple interfaces
 i = listdlg('PromptString',...
   'There is more then one interface matching your data. Select one!',...
   'SelectionMode','single',...
   'ListSize',[400 100],...
   'ListString',interface);
 interface = interface(i);
end

%% no interface - try generic interface
if isempty(interface)

  [d,options] = loadEBSD_generic(fname,varargin{:});
  
  if isempty(d)
    interface = '';
  else
    interface = 'generic';
  end
  
end

interface = char(interface);

