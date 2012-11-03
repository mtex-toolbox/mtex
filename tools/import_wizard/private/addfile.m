function addfile(list_handle,type,varargin)

%% get file names
if check_option(varargin,'file')
  [pathname, fnames, ext] = fileparts(get_option(varargin,'file'));
  fnames = {[fnames,ext]};
  if ~isempty(pathname), pathname = [pathname,filesep];end
else
  dataPath = getpref('mtex','ImportWizardPath');
  if isa(dataPath,'function_handle')
    dataPath = feval(dataPath);
  elseif strcmpi(dataPath,'workpath')
    dataPath = getappdata(list_handle,'workpath');
  end

  [fnames,pathname] = uigetfile( mtexfilefilter(),...
    'Select Data files',...
    'MultiSelect', 'on',dataPath);
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
    [newData interface options idata] = loadData(strcat(pathname,fnames(i)),type,interf{:},options{:});
  catch e %#ok<CTCH>
    errordlg(e.message);
    break;
  end

  if ~isempty(newData)
    oldData = getappdata(list_handle,'data');

    assertCS(oldData,newData);

    % store data
    setappdata(list_handle,'data',[oldData,newData]);
    setappdata(list_handle,'idata',[getappdata(list_handle,'idata'),idata]);
    setappdata(list_handle,'filename',[getappdata(list_handle,'filename'),strcat(pathname,fnames(i))]);

    % update file list
    set(list_handle, 'String',path2filename(getappdata(list_handle,'filename')));
    set(list_handle, 'Value',1);

    handles = getappdata(gcf,'handles');
    if isa(newData,'ODF')
      if check_option(newData,'interp')
        set(handles.method(1),'value',1);
        set(handles.method(2),'value',0);
      else
        set(handles.method(1),'value',0);
        set(handles.method(2),'value',1);
      end
    end



    drawnow; pause(0.01);
  end
end

%% store interface options
setappdata(list_handle,'options',options);
setappdata(list_handle,'interface',interface);

try
  handles = getappdata(gcf,'handles');
  set(handles.interface,'string',['Interface: ' interface]);
catch
end


function assertCS(oldData,newData)
if iscell(oldData),
  csO = get(oldData{1},'CS');
else
  csO = get(oldData,'CS');
end
if iscell(newData),
  csN = get(newData{1},'CS');
else
  csN = get(oldData,'CS');
end

if ~isempty(csO) && ~isempty(csN),
  if (csO ~= csN),
    error('Symmetry mismatch, I can''t handle this!');
  end
end
