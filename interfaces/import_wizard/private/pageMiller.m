function pageMiller(api)
% page for Miller indece input


gui = localCreatePage();
gui.entry = {};
gui.map   = {};

api.setWizardTitle('Miller Indices')
api.setWizardDescription('Correct Miller Indices')


api.Progress.enableNext(true);

api.setLeavePageCallback(@leavePage);
api.setGotoPageCallback(@gotoPage);



set(gui.hList       ,'Callback',@localUpdateGUI);
set(gui.hStructure  ,'Callback',@localUpdateIndices);
set(gui.hMiller     ,'Callback',@localUpdateIndices);


  function nextPage = leavePage
    
    nextPage = @pageFinish;
    
  end

  function gotoPage
    
    api.Progress.enableNext(true);
    
    localUpdateGUI();
    
  end

  function localUpdateGUI(source,event)
    
    data   = api.getData();
    files  = api.getFiles();
    
    gui.entry = {};
    gui.map   = {};
    for k=1:numel(data)
      [path,file,ext] = fileparts(files{k});
      pf = data{k};
      
      for j=1:pf.numPF
        
        h = char(pf({j}).h);
        entry = ['               ' file ext];
        entry(1:numel(h)) = h;
        
        gui.entry{end+1} =entry;
        gui.map{end+1}   =  [k,j];
      end
    end
    
    set(gui.hList,'String',gui.entry);
    
    val = get(gui.hList,'Value');
    
    map = gui.map{val};
    pf  = data{map(1)};
    
    
    h = pf.allH{map(2)};
    c = pf.c{map(2)};
    
    hkl = h.hkl';
    
    set(gui.hMiller(1),'String',int2str(hkl(1,:)));
    set(gui.hMiller(2),'String',int2str(hkl(2,:)));
    set(gui.hMiller(3),'Enable','off');
    if size(hkl,2) > 3
      set(gui.hMiller(3),'Enable',int2str(hkl(3,:)));
    end
    set(gui.hMiller(4),'String',int2str(hkl(end,:)));
    
    set(gui.hStructure,'String',xnum2str(c));
    
  end


  function localUpdateIndices(source,event)
    
    data   = api.getData();
    
    val = get(gui.hList,'Value');
    
    map = gui.map{val};
    
    hkl = get(gui.hMiller,'String');
    c   = str2num(get(gui.hStructure,'String'));
    
    hkl = cellfun(@str2num,hkl([1 2 4]),'UniformOutput',false);
    
    try
      assert(all(cellfun('prodofsize',hkl) == numel(c)));
      
      % set hkl
      data{map(1)}.allH{map(2)} = Miller(hkl{:},data{map(1)}.CS);
      
      % set superposition coefficients
      data{map(1)}.c{map(2)} = c;
      
      
      api.setData(data);
      
      localUpdateGUI();
    catch
      
    end
    
  end


  function gui = localCreatePage()
    page = api.hPanel;
    
    h = api.Spacings.PageHeight;
    w = api.Spacings.PageWidth;
    m = api.Spacings.Margin;
    fs = api.Spacings.FontSize;
    
    uicontrol(...
      'String','Imported Pole Figure Data Sets',...
      'Parent',page,...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',[0 h-15 w-160-m 15]);
    
    listbox = uicontrol(...
      'Parent',page,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'HorizontalAlignment','left',...
      'Max',2,...
      'Position',[0 45 w-160-m h-15-50],...
      'FontSize',fs,...
      'String',blanks(0),...
      'Style','listbox',...
      'Max',1,...
      'Value',1);
    
    mi = uibuttongroup('title','Miller Indeces',...
      'Parent',page,...
      'units','pixels',...
      'FontSize',fs,...
      'position',[w-160 h-162 160 150]);
    
    ind = {'h','k','i','l'};
    for k=1:4
      uicontrol(...
        'Parent',mi,...
        'String',ind{k},...
        'HitTest','off',...
        'Style','text',...
        'HorizontalAlignment','right',...
        'FontSize',fs,...
        'Position',[m 132-30*k 10 15]);
      miller(k) = uicontrol(...
        'Parent',mi,...
        'BackgroundColor',[1 1 1],...
        'FontName','monospaced',...
        'HorizontalAlignment','right',...
        'FontSize',fs,...
        'Position',[2*m+10 130-30*k 120 22],...
        'String',blanks(0),...
        'Style','edit');
    end
    
    sc = uibuttongroup('title','Structure Coefficients',...
      'Parent',page,...
      'FontSize',fs,...
      'units','pixels','position',[w-160 h-230 160 55]);
    
    uicontrol(...
      'Parent',sc,...
      'String','c',...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','right',...
      'Position',[m 10 10 15]);
    
    structur = uicontrol(...
      'Parent',sc,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'FontSize',fs,...
      'HorizontalAlignment','right',...
      'Position',[2*m+10 10 120 22],...
      'String',blanks(0),...
      'Style','edit');
    %
    uicontrol(...
      'String',['For superposed pole figures seperate multiple Miller indece ', ...
      'and structure coefficients by space!'],...
      'Parent',page,...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',[0 0 w-20 30]);
    
    gui.hList      = listbox;
    gui.hMiller    = miller;
    gui.hStructure = structur;
    
  end

end
