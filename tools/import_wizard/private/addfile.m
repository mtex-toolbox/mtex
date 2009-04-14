function addfile(list_handle,varargin)

%% get file names
if check_option(varargin,'file')
  [pathname, fnames, ext] = fileparts(get_option(varargin,'file'));
  fnames = {[fnames,ext]};
  pathname = [pathname,filesep];
else
  [fnames,pathname] = uigetfile( mtexfilefilter(),...
    'Select Data files',...
    'MultiSelect', 'on',getappdata(list_handle,'workpath'));

  if ~iscellstr(fnames)
    if fnames ~= 0
      fnames = {fnames};
    else
      return;
    end
  end;
end
setappdata(list_handle,'workpath',pathname);


%% load data
options = getappdata(list_handle,'options');
interface = getappdata(list_handle,'interface');
pause(0.1);

for i=1:length(fnames)
  
  if ~isempty(interface)
    interf = {'interface',interface};
  else
    interf = {};
  end

%% try to load one file

  try
    if check_option(varargin,'EBSD')
      [data,interface,options] = ...
        loadEBSD(strcat(pathname,fnames(i)),interf{:},options{:});
      idata = length(data);
    else
      [data,interface,options,idata] = ...
        loadPoleFigure(strcat(pathname,fnames(i)),interf{:},options{:});
    end
  catch
    errordlg(errortext);
    break;
  end
  
  if ~isempty(data)
 
    % store data
    setappdata(list_handle,'data',[getappdata(list_handle,'data'),data]);
    setappdata(list_handle,'idata',[getappdata(list_handle,'idata'),idata]);
    setappdata(list_handle,'filename',[getappdata(list_handle,'filename'),strcat(pathname,fnames(i))]);
   
    % update file list
    set(list_handle, 'String',path2filename(getappdata(list_handle,'filename')));
    set(list_handle,'Value',1);
    drawnow; pause(0.01);
  end
end

%% store interface options
setappdata(list_handle,'options',options);
setappdata(list_handle,'interface',interface);
