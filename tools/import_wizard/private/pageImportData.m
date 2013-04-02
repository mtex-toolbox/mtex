function pageImportData( api )
% pages for data import


api.setWizardTitle('Import Wizard')
api.setWizardDescription('Select Data Files')

api.setLeavePageCallback(@leavePage);
api.setGotoPageCallback(@gotoPage);

gui = localCreatePage();

% register callbacks
set(gui.hAdd  ,'CallBack',@localAddData)
set(gui.hDel  ,'CallBack',@localDeleteData)
set(gui.hUp   ,'CallBack',{@localShiftData,-1})
set(gui.hDown ,'CallBack',{@localShiftData,+1})


  function nextPage = leavePage
    
    data = api.getData();
    
    varname = {'pf','ebsd','odf','tensor'};
    varname = varname{mod(api.getDataType(),4)+1};
    api.Export.setWorkspaceName(varname);
    
    if numel(data) > 1 && isa(data{1},'EBSD')
      nextPage = @page3dEBSD;
    else
      nextPage = @pageCS;
    end
    
  end

  function gotoPage
    
    api.Progress.enableFinish(false);
    
    localUpdateGUI();
    
  end

  function localDeleteData(source,event)
    
    activePanels = get(gui.dataPanels,'visible');
    type = find(strcmpi(activePanels,'on'),1,'first');
    
    hList     = gui.lists(type);
    
    delEntry = get(hList,'Value');
    
    data  = api.getData(type);
    files = api.getFiles(type);
    
    if ~isempty(data)
      data(delEntry) = [];
      files(delEntry) = [];
      api.setData(data,type);
      api.setFiles(files,type);
      
      set(hList,'Value',1);
      
      localUpdateLists();
    end
    
  end

  function localShiftData(source,event,shift)
    
    activePanels = get(gui.dataPanels,'visible');
    type = find(strcmpi(activePanels,'on'),1,'first');
    
    hList     = gui.lists(type);
    
    shiftEntry = get(hList,'Value');
    
    data  = api.getData(type);
    files = api.getFiles(type);
    
    if ~isempty(data)
      newPos = shiftEntry+shift;
      
      r = 0 < newPos & newPos <= numel(data);
      
      newPos     = newPos(r);
      shiftEntry = shiftEntry(r);
      
      tempdata          = data(newPos);
      tempfiles         = files(newPos);
      data(newPos)      = data(shiftEntry);
      files(newPos)     = files(shiftEntry);
      data(shiftEntry)  = tempdata;
      files(shiftEntry) = tempfiles;      
      
      api.setData(data,type);
      api.setFiles(files,type);
      
      set(hList,'Value',newPos)
      
      localUpdateLists();
    end
    
    
  end

  function localAddData(source,event)
    
    activePanels = get(gui.dataPanels,'visible');
    type = find(strcmpi(activePanels,'on'),1,'first');
    
    if api.hasData() && all(api.getDataType() ~= type) && ...
        (~(all(type >= 4) && all(api.getDataType() >= 4)) ||  any(api.getDataType() < 4))
      choice =  questdlg({'You already imported data with a different type',...
        'Adding Data in a different mode remove all currently imported data'},'Switch Import Mode');
      switch choice
        case 'Yes'
          api.clearAllData();
        otherwise
          return
      end
      
    end
    
    [files,path] = uigetfile( '*.*',...
      'Select Data files',...
      'MultiSelect', 'on',mtexDataPath);
    
    if isnumeric(files)
      return
    end    
    
    api.loadDataFiles(type,strcat({path},ensurecell(files)));
    
    localUpdateLists();
    
  end

  function localUpdateGUI(source,event)
    
    localUpdateLists();
    
    state = get(gui.modeTabs,'visible');
    type = find(strcmpi(state,'on'),1,'last');
    
    title = ['Import ' gui.modes{type}];
    api.setWizardTitle(title);
    
  end

  function localUpdateLists()
    
    for type = 1:numel(gui.dataPanels)
      m = api.getFiles(type);
      fnames = cell(size(m));
      for k=1:numel(m)
        [a,file,ext] = fileparts(m{k});
        fnames{k} = [file ext];
      end
      set(gui.lists(type),'String',fnames);
    end
    
    api.Progress.enableNext(api.hasData());
    api.Progress.enablePlot(api.hasData());
    api.Progress.enableFinish(api.hasData());
    
     
    interf = api.Export.getInterface();
  
    if ~isempty(interf)
      interf = ['Interface: ' interf];
    else
      interf = '';
    end
    
    set(gui.hInterface,'String',interf);
    
  end

  function gui = localCreatePage()
    
    page = api.hPanel;
    
    w    = api.Spacings.PageWidth;
    h    = api.Spacings.PageHeight;
    
    bw   = api.Spacings.ButtonHeight;
    m    = api.Spacings.Margin;
    % subWidth = w-;
    
    modes = {'Pole Figures','EBSD','ODF','Tensor'};
    
    if api.hasData()
      slots = api.getDataType();
      select = mod(slots(1),4)+1;
    elseif ~isempty(api.presetDataImport)
      select = api.presetDataImport;
    else
      select = 1;
    end
    
    modeTabGroup = uitabpanel(...
      'Parent',page,...
      'TabPosition','lefttop',...
      'units','pixel',...
      'position',[0,0,w,h],...
      'Margins',{[0,0,-2,0],'pixels'},...
      'PanelBorderType','beveledout',...
      'Title',modes,... %,'Background','Defocussing','Defocussing BG'},...
      'FrameBackgroundColor',get(gcf,'color'),...
      'PanelBackgroundColor',get(gcf,'color'),...
      'TitleForegroundColor',[0,0,0],...
      'selectedItem',select);
    
    modeTabs = getappdata(modeTabGroup,'panels');
    
    if ~api.isPublishMode || select == 1
      
      pfTabGroup = uitabpanel(...
        'Parent',modeTabs(1),...
        'TabPosition','lefttop',...
        'units','pixel',...
        'position',[0,0,w-bw-2*m,h-35],...
        'Margins',{[0,0,-2,0],'pixels'},...
        'PanelBorderType','beveledout',...
        'Title',{'Data','Background','Defocussing','Defocussing BG'},...
        'FrameBackgroundColor',get(gcf,'color'),...
        'PanelBackgroundColor',get(gcf,'color'),...
        'TitleForegroundColor',[0,0,0],...
        'selectedItem',1);
      
      pfTabs = getappdata(pfTabGroup,'panels');
      
      %       set(pfTabs,'BorderType','none');
      
      datapanels = [modeTabs(2:end) pfTabs];
      
    else
      
      datapanels = modeTabs(2:end);
      
    end
    
    pos = @(h) [w-m-bw h  bw bw];
    add = uicontrol(...
      'Parent',page,...
      'cdata',getIcon('add'),...
      'TooltipString','add data file',...
      'Position',pos(h-m-2*bw));
    
    del = uicontrol(...
      'Parent',page,...
      'cdata',getIcon('delete'),...
      'TooltipString','remove data file',...
      'Position',pos(h-m-3*bw));
    
    up = uicontrol(...
      'Parent',page,...
      'style','pushbutton',...
      'cdata',getIcon('up'),...
      'TooltipString','move data file upwards',...
      'Position',pos(m+bw));
    
    down = uicontrol(...
      'cdata',getIcon('down'),...
      'TooltipString','move data file downwards',...
      'style','pushbutton',...
      'Parent',page,...
      'Position',pos(m));
    
    
    interf = uicontrol(...
      'Parent',page,...
      'Style','text',...
      'Position',[w-200-m h-21 200 16],...
      'HorizontalAlignment','right',...
      'String','interface');
    
    for k = 1:length(datapanels)
      if k <=3
        lh = 48;
      else
        lh = 75;
      end
      
      if ~(k <=3 && api.isPublishMode && select == 1)
        lists(k) = uicontrol(...
          'Parent',datapanels(k),...
          'BackgroundColor',[1 1 1],...
          'FontName','monospaced',...
          'HorizontalAlignment','left',...
          'Max',2,...
          'Position',[m m w-3*m-bw h-lh],...
          'String',blanks(0),...
          'Style','listbox',...
          'Value',1);
      end
      
    end
    
    gui.hAdd         = add;
    gui.hDel         = del;
    gui.hUp          = up;
    gui.hDown        = down;
    
    gui.hInterface   = interf;
    
    gui.modeTabGroup = modeTabGroup;
    gui.modes        = modes;
    gui.modeTabs     = modeTabs;
    
    for k=1:numel(gui.modeTabs)
      addlistener(gui.modeTabs(k),'Visible','PostSet',@localUpdateGUI);
    end
    
    gui.dataPanels = datapanels;
    gui.lists = lists;
    gui.interface = {'EBSD','ODF','Tensor',...
      'PoleFigure','PoleFigure','PoleFigure','PoleFigure'};
    
    
    function cdata = getIcon(type)
      
      switch type
        case 'add'
          cdata = [ ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
            NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            ];
        case 'delete'
          cdata = [ ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
            NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            ];
        case 'up'
          cdata = [ ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN   0   0   0   0 NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN   0   0   0   0   0   0 NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN   0   0   0   0   0   0   0   0 NaN NaN NaN NaN ; ...
            NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
            NaN NaN   0   0   0   0   0   0   0   0   0   0   0   0 NaN NaN ; ...
            NaN   0   0   0   0   0   0   0   0   0   0   0   0   0   0 NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            ];
        case 'down'
          cdata = [ ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN   0   0   0   0   0   0   0   0   0   0   0   0   0   0 NaN ; ...
            NaN NaN   0   0   0   0   0   0   0   0   0   0   0   0 NaN NaN ; ...
            NaN NaN NaN   0   0   0   0   0   0   0   0   0   0 NaN NaN NaN ; ...
            NaN NaN NaN NaN   0   0   0   0   0   0   0   0 NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN   0   0   0   0   0   0 NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN   0   0   0   0 NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN   0   0 NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN ; ...
            ];
      end
      
      cdata = repmat(cdata,[1 1 3]);
      
    end
    
  end

end