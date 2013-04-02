function pageFinish(api)

gui = localCreatePage();

api.setWizardTitle('Import Data');
api.setWizardDescription('Select Method');

api.setLeavePageCallback(@leavePage);
api.setGotoPageCallback(@gotoPage);

set(gui.hVarname     ,'Callback',          @localExportBehavior);
set(gui.hFinishGroup ,'SelectionChangeFcn',@localExportBehavior);


  function nextPage = leavePage
    
    nextPage = [];
    
  end

  function gotoPage
    
    api.Progress.enableNext(false);
    api.Progress.enableFinish(true);
    
    localUpdateGUI();
    
  end

  function localExportBehavior(varargin)
    
    varName = regexprep(get(gui.hVarname,'String'),'\s','');
    api.Export.setWorkspaceName(varName);
    
    doScript = get(gui.hRadio(1),'Value');
    api.Export.setGenerateScriptFile(doScript);

    localUpdateGUI();
    
  end

  function localUpdateGUI()
    
    doScript = api.Export.getGenerateScriptFile();
    varname  = api.Export.getWorkspaceName();
    
    val_alias = {'off','on'};
    set(gui.hVarname,'Visible',val_alias{~doScript+1})
    set(gui.hVarname,'String',varname);
    
    set(gui.hRadio(1),'Value',doScript)
    set(gui.hRadio(2),'Value',~doScript)    
    
    data = api.getData();
    data = [data{:}];
    str  = char(data);
    
    set(gui.hTitle,'String',[ 'Summary of ' class(data) ' data to be imported:']);
    set(gui.hPreview,'String',str(:,1:min(end,80)));
    
  end

  function gui = localCreatePage()
    % final import wizard page
    page = api.hPanel;
    
    h = api.Spacings.PageHeight;
    w = api.Spacings.PageWidth;
    m = api.Spacings.Margin;
    
    summarytitle = uicontrol(...
      'Parent',page,...
      'String','Data summary:',...
      'Position',[1 h-20-m w 20],...
      'Style','text',...
      'HorizontalAlignment','left');
    
    preview = uicontrol(...
      'Parent',page,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'HorizontalAlignment','left',...
      'Max',2,...
      'Position',[1 h-210 w-2 175],...
      'String',blanks(0),...
      'Style','edit');
    
    finish_exp = uibuttongroup('title','Import to',...
      'Parent',page,...
      'units','pixels','position',[1 h-270 w-2 50]);
    
    radio_exp(2) = uicontrol(...
      'Parent',finish_exp,...
      'HorizontalAlignment','left',...
      'Position',[160 10 150 20 ],...
      'String',' workspace variable',...
      'Value',0,...
      'Style','radio');
    
    radio_exp(1) = uicontrol(...
      'Parent',finish_exp,...
      'HorizontalAlignment','left',...
      'Position',[10 10 150 20 ],...
      'String',' script (m-file)',...
      'Value',1,...
      'Style','radio');
    
    workspace(1) = uicontrol(...
      'Parent',page,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'HorizontalAlignment','left',...
      'Position',[320 15  150 22 ],...
      'String',blanks(0),...
      'Style','edit');
    
    gui.hFinishGroup = finish_exp;
    gui.hRadio       = radio_exp;
    gui.hVarname     = workspace;
    gui.hTitle       = summarytitle;
    gui.hPreview     = preview;
    
  end

end