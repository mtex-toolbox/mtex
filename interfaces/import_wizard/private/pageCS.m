function pageCS(api,phaseNumber)

api.setWizardTitle('Crystal Reference Frame');
api.setWizardDescription('Crystal Symmetry')

api.setLeavePageCallback(@leavePage);
api.setGotoPageCallback(@gotoPage);


gui = localCreatePage();


nPhases = 0;
if nargin > 1
  currentPhase = phaseNumber;
else
  currentPhase = 1;
end


CS = 'not available';


% register callbacks
set(gui.hColor    ,'ItemStateChangedCallback',@localUpdateCS);
set(gui.hCrystal  ,'Callback',@localUpdateCS);
set(gui.hMineral  ,'Callback',@localUpdateCS);
set(gui.hAxes     ,'Callback',@localUpdateCS);
set(gui.hAngle    ,'Callback',@localUpdateCS);
set(gui.hAlignment    ,'Callback',@localUpdateCS);    
set(gui.hMGroup   ,'SelectionChangeFcn',@localUpdateCS);
set(gui.hCSGroup  ,'SelectionChangeFcn',@localUpdateCS);

set(gui.hSearchCIF,'CallBack',@lookupMineral);


  function nextPage = leavePage()
        
    if nPhases > currentPhase
      nextPage = @(api) pageCS(api,currentPhase+1);
    else
      nextPage = @pageSS;
    end
    
  end

  function gotoPage
    
    api.Progress.enableNext(true);
    
    
    data = api.getData();
    data = data{1};
    
    
    if isa(data,'EBSD')
      
      nPhases = numel(data.CSList);
      
      CS = data.CSList{currentPhase};
            
      api.setWizardTitle(['Crystal Reference Frame for Phase '  ...
        num2str(data.phaseMap(currentPhase))]);
      
    else
      
      CS = data.CS;
      nPhases = 1;
      
    end
    
    localUpdateGUI();
    
  end

  function localUpdateGUI()
    
    if ischar(CS)
      
      set(gui.hIndexed(1),'Value',0);
      set(gui.hIndexed(2),'Value',1);
      
      set(gui.hCS,'Enable','off');
      set(gui.hMineral,'Enable','off');
      gui.hColor.setSelectedColor([]);
      gui.hColor.setEnabled(false);
      
      set(gui.hMineral,'string',CS);
      
    else
      
      set(gui.hMineral,'enable','on');
      gui.hColor.setEnabled(true);
      set(gui.hCS,'enable','on');
      
      set(gui.hIndexed(1),'Value',1);
      set(gui.hIndexed(2),'Value',0);
      
      csname = strmatch(CS.pointGroup,SymmetryList);
      set(gui.hCrystal,'value',csname(1));
      
      if isempty(CS.color)
        gui.hColor.setSelectedColor([]);
      else
        rgb = str2rgb(CS.color);
        gui.hColor.setSelectedColor(java.awt.Color(rgb(1),rgb(2),rgb(3)));
      end
      
      % set alignment
      if any(CS.Laue.id == [2,5,8,11,18,21,24,35,40]) %,{'-1','2/m','-3','-3m','6/m','6/mmm'}))
        set(gui.hAlignment,'enable','on');
        al = [CS.alignment,{'',''}];
        set(gui.hAlignment(1),'value',find(strcmp(AlignmentList,al{1})));
        set(gui.hAlignment(2),'value',find(strcmp(AlignmentList,al{2})));
      else
        set(gui.hAlignment,'Value',1,'Enable','off');
      end
      
      % set axes
      for k=1:3
        set(gui.hAxes(k),'String',norm(CS.axes(k)));        
      end
      
      set(gui.hAngle(1),'String',CS.alpha / degree);
      set(gui.hAngle(2),'String',CS.beta / degree);
      set(gui.hAngle(3),'String',CS.gamma / degree);
      
      
      % set whether axes and angles can be changed
      if ~any(CS.Laue.id==[2,5,8,11]), set(gui.hAngle, 'Enable', 'off'); end
      
      % set mineral
      set(gui.hMineral,'string',CS.mineral);
    end
    
  end

  function localUpdateCS(source,event)    
    
    in = find([get(gui.hIndexed(1),'value') get(gui.hIndexed(2),'value')]);
    
    if in > 1
      
      CS = 'notIndexed';
      
    else
      
      cs = get(gui.hCrystal,'Value');
      cs = SymmetryList(cs);
      %cs = strtrim(cs{1}(1:6));
      
      for k=1:3
        axis{k}  =  str2double(get(gui.hAxes(k),'String')); %#ok<AGROW>
        angle{k} =  str2double(get(gui.hAngle(k),'String')); %#ok<AGROW>
      end
      
      mineral = get(gui.hMineral,'string');
      
      al1 = get(gui.hAlignment(1),'Value');
      al2 = get(gui.hAlignment(2),'Value');
      al = AlignmentList;
      
      
      col = gui.hColor.getSelectedColor;
      if isempty(col)
        rgb = col;
      else
        rgb = [col.getRed,col.getGreen,col.getBlue]./255;
      end
      
      try
        CS = crystalSymmetry(cs,[axis{:}],[angle{:}]*degree,al{al1},al{al2},...
          'mineral',mineral,'color',rgb);
      catch %#ok<CTCH>
        CS = crystalSymmetry(cs,[axis{:}],[angle{:}]*degree,'mineral',mineral,'color',rgb);
      end
    end
    
    
    % update data
    data = api.getData();
    
    for k=1:numel(data)
      
      if isa(data{k},'EBSD')
        
        data{k}.CSList{currentPhase} = CS;
                
      else
        
        data{k}.CS= CS;
        
      end
      
      
    end
    
    api.setData(data);
    
    localUpdateGUI();
    
  end

  function lookupMineral(source,event)    
    
    [fname,pathName] = uigetfile(fullfile(mtexCifPath,'*.cif'),'Select cif File');
    
    if fname ~= 0
      
      name = [pathName,fname];
      try
        CS = loadCIF(name);
        localUpdateGUI();
        localUpdateCS();
      catch %#ok<CTCH>
        errordlg(errortext);
      end
      
    end
    
  end

  function [ sym ] = SymmetryList( index )
    
    sym = struct2cell(symmetry.pointGroups);
    sym = squeeze(sym(2,1,:));
        
    if nargin > 0, sym = sym(index) ; end
    
  end

  function al = AlignmentList
    
    xyz = {'X','Y','Z'};
    abc = {'a','b','c','a*','b*','c*'};
    
    al = {};
    for ix = 1:3
      al = [al cellfun(@(a) [xyz{ix},'||',a],abc,'UniformOutput',false)]; %#ok<AGROW>
    end
    al = [{''} al];
    
  end

  function gui = localCreatePage()
    
    page = api.hPanel;
    
    w    = api.Spacings.PageWidth;
    h    = api.Spacings.PageHeight;
    m    = api.Spacings.Margin;
    bW   = api.Spacings.ButtonWidth;
    bH   = api.Spacings.ButtonHeight;
    fs   = api.Spacings.FontSize;
    
    
    mineralGroup = uibuttongroup('title','Mineral',...
      'Parent',page,...
      'FontSize',fs,...
      'units','pixels','position',[1 h-115 w 115]);
    
    indexed(1) = uicontrol(...
      'Parent',mineralGroup,...
      'String','Indexed',...
      'FontSize',fs,...
      'Style','radio',...
      'Position',[m 75 150 15]);
    
    rW = 110;
    
    indexed(2) = uicontrol(...
      'Parent',mineralGroup,...
      'String','Not Indexed',...
      'FontSize',fs,...
      'Style','radio',...
      'Position',[rW 75 150 15]);
    
    
    uicontrol(...
      'Parent',mineralGroup,...
      'String','mineral name',...
      'FontSize',fs,...
      'HitTest','off',...
      'Style','text',...
      'HorizontalAlignment','left',...
      'Position',[m 45 100 15]);
    
    
    mineral = uicontrol(...
      'Style','edit',...
      'FontSize',fs,...
      'Parent',mineralGroup,...
      'BackgroundColor',[1 1 1],...
      'Position',[rW 45 2*bW 20],...
      'HorizontalAlignment','left',...
      'string','');
    
    uicontrol(...
      'Parent',mineralGroup,...
      'String','plotting color',...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',[m 15 130 15]);
    
    warning('off','MATLAB:ui:javacomponent:FunctionToBeRemoved');
    color = com.jidesoft.combobox.ColorComboBox;
    color = javacomponent(color,[rW 10 2*bW 25],mineralGroup);
    color.setColorValueVisible(false)
    warning('on','MATLAB:ui:javacomponent:FunctionToBeRemoved');
        
    look = uicontrol(...
      'Parent',mineralGroup,...
      'String','Load Cif File',...
      'FontSize',fs,...
      'Position',[333 42 bW bH]);
    
    csGroup = uibuttongroup('title','Crystal Coordinate System',...
      'Parent',page,...
      'FontSize',fs,...
      'units','pixels','position',[1 h-115-135-m w 135],...
      'SelectionChangeFcn',@localUpdateGUI);
    
    uicontrol(...
      'Parent',csGroup,...
      'String','Point Group',...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',[10 85 80 15]);
    
    crystal = uicontrol(...
      'Parent',csGroup,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',[95 85 180 20],...
      'String',blanks(0),...
      'Style','popup',...
      'String',SymmetryList,...
      'Value',1);
    
    
    for k=1:2
      axis_alignment(k) = uicontrol(...
        'Parent',csGroup,...
        'BackgroundColor',[1 1 1],...
        'FontName','monospaced',...
        'FontSize',fs,...
        'HorizontalAlignment','left',...
        'Position',[285+(k-1)*(bW+m) 85 bW 20],...
        'String',blanks(0),...
        'Style','popup',...
        'String',AlignmentList,...
        'Value',1);
    end
    
    uicontrol(...
      'Parent',csGroup,...
      'String','Axis Length',...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',[10 50 100 15]);
    uicontrol(...
      'Parent',csGroup,...
      'String','Axis Angle',...
      'FontSize',fs,...
      'HitTest','off',...
      'Style','text',...
      'HorizontalAlignment','left',...
      'Position',[10 15 100 15]);
    
    axis = {'a','b','c'};
    angle=  {'alpha', 'beta', 'gamma'};
    for k=1:3
      uicontrol(...
        'Parent',csGroup,...
        'String',axis{k},...
        'HitTest','off',...
        'Style','text',...
        'FontSize',fs,...
        'HorizontalAlignment','right',...
        'Position',[130+120*(k-1) 50 30 15]);
      uicontrol(...
        'Parent',csGroup,...
        'String',angle{k},...
        'HitTest','off',...
        'Style','text',...
        'FontSize',fs,...
        'HorizontalAlignment','right',...
        'Position',[110+120*(k-1) 15 50 15]);
      ax(k) = uicontrol(...
        'Parent',csGroup,...
        'BackgroundColor',[1 1 1],...
        'FontName','monospaced',...
        'HorizontalAlignment','left',...
        'FontSize',fs,...
        'Position',[165+120*(k-1) 45 60 25],...
        'String',blanks(0),...
        'Style','edit');
      an(k) = uicontrol(...
        'Parent',csGroup,...
        'BackgroundColor',[1 1 1],...
        'FontName','monospaced',...
        'FontSize',fs,...
        'HorizontalAlignment','left',...
        'Position',[165+120*(k-1) 10 60 25],...
        'String',blanks(0),...
        'Style','edit');
    end
    
    gui.hMineral   = mineral;
    gui.hIndexed   = indexed;
    gui.hColor     = color;
    gui.hCrystal   = crystal;
    gui.hAlignment = axis_alignment;
    gui.hAxes      = ax;
    gui.hAngle     = an;
    gui.hSearchCIF = look;
    
    gui.hMGroup    = mineralGroup;
    gui.hCSGroup   = csGroup;
    gui.hCS = [crystal axis_alignment ax an];
    
  end


end
