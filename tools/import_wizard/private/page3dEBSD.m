function page3dEBSD( api )


getEBSD = api.Export.getOptEBSD;
setEBSD = api.Export.setOptEBSD;

gui = localCreatePage();

api.setWizardTitle('Import Wizard EBSD');
api.setWizardDescription('3d Data Z-Values');


api.setLeavePageCallback(@leavePage);
api.setGotoPageCallback(@gotoPage);

% set(gui.h3dRadio,'Callback',@localUpdate3d)
set(gui.h3dGroup  ,'SelectionChangeFcn',@localUpdate3d)
set(gui.hUpdate   ,'Callback'          ,@localUpdate3d)
% set(gui.hTable,'DataChangedCallback',@localUpdate3d)



  function nextPage = leavePage
    
    % store z-values, while DataChangedCallback fails somehow
    localUpdate3d([],[]);
    
    nextPage = @pageCS;
    
  end


  function gotoPage
    
    api.Progress.enableNext(true);
    
    localUpdateGUI();
    
  end

  function localUpdate3d(source,event)
    
    setEBSD('is3d',get(gui.h3dRadio(2),'value'));
    
    tdata = cell(get(gui.hTable,'Data'));
    Z = tdata(:,2);
    x = cellfun('isclass',Z,'char');
    Z(x) = cellfun(@str2num,Z(x),'UniformOutput',false);
    Z(cellfun('isempty',Z)) = {0};
    
    setEBSD('Z',Z);
    
    localUpdateGUI();
    
  end

  function localUpdateGUI()
    
    set(gui.h3dRadio(1),'Value',~getEBSD('is3d'));
    set(gui.h3dRadio(2),'Value',getEBSD('is3d'));
    
    files = api.getFiles();
    [pathes,fnames,ext] = cellfun(@fileparts,files,'Uniformoutput',false);
    fnames = strcat(fnames,ext);
    
    Z = getEBSD('Z');
    if isempty(Z) || numel(Z) ~= numel(files)
      Z = num2cell(1:numel(files));
    end
    
    state = {'off','on'};
    
    set(gui.hTable,  'data',[fnames(:),Z(:)]);
    set(gui.hTable,  'Visible',getEBSD('is3d'));
    set(gui.hUpdate, 'Visible',state{1+getEBSD('is3d')});
    
  end

  function gui = localCreatePage()
    
    page = api.hPanel;
    
    h    = api.Spacings.PageHeight;
    w    = api.Spacings.PageWidth;
    m    = api.Spacings.Margin;
    bH   = api.Spacings.ButtonHeight;
    bW   = api.Spacings.ButtonWidth;
    fs   = api.Spacings.FontSize;
    
    
    group3d = uibuttongroup(...
      'parent',page,...
      'Units','pixels',...
      'FontSize',fs,...
      'position',[1,0,w,h],...
      'Title','3d EBSD Data');
    
    is3d(1) = uicontrol(...
      'Parent',group3d,...
      'Style','radio',...
      'FontSize',fs,...
      'String',' All data files lie on the same surface',...
      'Value',1,...
      'position',[m h-m-1.5*bH w-2*m bH]);
    
    is3d(2) = uicontrol(...
      'Parent',group3d,...
      'Style','radio',...
      'FontSize',fs,...
      'String',' Each data file is a serial section',...
      'Value',0,...
      'position',[m h-m-2.5*bH w-2*m bH]);
    
    update = uicontrol(...
      'Parent',group3d,...
      'style','pushbutton',...
      'FontSize',fs,...
      'String','Update Table',...
      'Position',[w-bW-m h-m-2.5*bH bW bH]);
    
    if verLessThan('matlab','7.6'),  v0 = {}; else  v0 = {'v0'}; end
    
    cdata =  {'Z-Layer Data Source','Z-Value'};
    
    table = uitable(v0{:},'parent',page,...
      'Data',{'filename',0},...
      'Position',[m,m,w-2*m,h-3*bH-2*m],...
      'ColumnNames',cdata,...
      'ColumnWidth',[w/2-10-2*m]);
    
    gui.h3dGroup = group3d;
    gui.h3dRadio = is3d;
    gui.hTable   = table;
    gui.hUpdate  = update;
    
  end

end
