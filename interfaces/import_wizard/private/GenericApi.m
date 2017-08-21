function api = GenericApi( api )
%IMPORTGUIPROGRESS Summary of this function goes here
%   Detailed explanation goes here



api.setWizardTitle([api.Type ' Generic Interface']);
api.setWizardDescription('Select Data Format');


state  = {'off','on'};

codes  = localCreateCodes();
[proposedColNames,proposedConvention] = matchColumns();


gui    = localCreateBottomGUIControls();
gui    = localCreatePage(gui);

Options      = {};
api.getOptions   = @getOptions;

% set callbacks
set(gui.hCancel           ,'Callback',@cancelCallback   );
set(gui.hHeader           ,'Callback',@headerCallback   );
set(gui.hFinish           ,'CallBack',@finishCallback   );

set(gui.hHeaderTable      ,'DataChangedCallback',@localUpdateTableHeaders)
set(gui.hAngleConvention  ,'Callback',@localUpdateTableHeaders)

enableHeader(~isempty(api.Header))
localUpdateTableHeaders()


  function [colNames,convention] = matchColumns()
    
    matchcount = zeros(size(codes));
    colNames = cell(size(codes));
    
    for k=1:numel(codes)
      colNames{k} = api.Columns;
      name = api.Columns;
      name = regexprep(name,'Euler1|Euler 1','phi1');
      name = regexprep(name,'Euler2|Euler 2','Phi');
      name = regexprep(name,'Euler3|Euler 3','phi2');
      
      required = codes(k).fields(codes(k).mandatory);
      for l=1:numel(required)
        matches = ~cellfun('isempty',strfind(lower(name),lower(required{l})));
        if any(matches)          
          matchcount(k) = matchcount(k) +1;
          
          %if there multiple matches take the one with the fewest chracters
          [tmp,pos] = min(cellfun('size',name(matches),2));
          ind = find(matches);
          
          colNames{k}(ind(pos))  = required(l);
        end
      end
    end
    
    [a,convention] = max(matchcount);
    colNames = colNames{convention};
    
  end

  function localUpdateTableHeaders(varargin)
    
    dataTable = gui.hDataTable;
    headerTable = gui.hHeaderTable;
    
    val = get(gui.hAngleConvention(1),'Value');
    
    values =  codes(val).fields;
    
    state = {'off','on'};
    set(gui.hAngleConvention(2),'Enable',state{1+codes(val).unit});
    set(gui.hAngleConvention(3),'Visible',state{1+codes(val).rotation});
    
    colNames = cell(get(headerTable,'data'));
    n = numel(colNames);
    
    colNames(cellfun('isempty',colNames)) = {'ignore'};
    
    for col = reshape(strmatch('---',colNames),1,[])
      pos = strcmpi(colNames{col},values);
      if any(pos)
        sp = cumsum(strncmpi('---',values,3));
        nv = find(sp(pos) == sp);
        nval = values(nv(2:end));
        colNames(col+(0:numel(nval)-1)) = nval;
        for j=col:col+numel(nval)-1
          if j <= n
            headerTable.getTableModel.setValueAt(java.lang.String(colNames{j}),0,j-1);
          end
        end
      end
    end
    
    try
      headerTable.getTable.setShowHorizontalLines(false);
      
      cb = javax.swing.JComboBox(values);
      cb.setFont(java.awt.Font('sans', 0, 13));
      cb.setMaximumRowCount(100);
      cb.setEditable(true);
      editor = javax.swing.DefaultCellEditor(cb);
      
      
      dataCols = dataTable.getTable.getColumnModel;
      headerCols = headerTable.getTable.getColumnModel;
      
      for i = 1:numel(headerTable.getColumnNames)
        headerCols.getColumn(i-1).setCellEditor(editor);
        headerCols.getColumn(i-1).setHeaderValue(api.Columns{i});
        dataCols.getColumn(i-1).setHeaderValue(colNames{i});
      end
      
      dataTable.getTable.updateUI;
      headerTable.getTable.updateUI;
      
    catch
    end
    
    validateColumnNames();
    
  end

  function validateColumnNames()
    
    colNames = cell(get(gui.hHeaderTable,'data'));
    
    val = get(gui.hAngleConvention(1),'Value');
    req = codes(val).fields(codes(val).mandatory);
    
    colNames = colNames(~cellfun('isempty',colNames));
    
    if all(ismember(lower(req),lower(colNames)))
      enableFinish(true);
    else
      enableFinish(false);
      % more fields required
    end
    
  end

  function opts = getOptions()
    
    opts = Options;
    
  end

  function s = localCreateCodes()
    
    % polefigure & vector3d
    switch api.Type
      case {'PoleFigure','vector3d'}
        names = {...
          'Spherical (Polar,Azimuth)';
          'Spherical (Latitude,Longitute)';
          'Vector (x,y,z)'; };
        fields = {...
          {'Polar Angle','Azimuth Angle'};
          {'Latitude','Longitude'};
          {'x','y','z'}; };
        
        fields = cellfun(@(x) ['--- Coordinates  -----------' x] ,fields,'Uniformoutput',false);
        
        isDegree = {true;true;false};
        isRotation = false;
      case {'EBSD','ODF','Orientation'}
        names = {...
          'Bunge (phi1 Phi phi2) ZXZ';
          'Matthies (alpha,beta,gamma) ZYZ';
          'Roe (Psi,Theta,Phi)';
          'Kocks (Psi,Theta,phi)';
          'Canova (omega,Theta,phi)';
          'Quaternion'; };
        fields = {...
          {'phi1','Phi','phi2'};
          {'alpha','beta','gamma'};
          {'Psi','Theta','Phi'};
          {'Psi','Theta','phi'};
          {'omega','Theta','phi'};
          {'Quat real','Quat i','Quat j','Quat k'}; };
        fields = cellfun(@(x) ['--- Rotation ------------' x] ,fields,'Uniformoutput',false);
        isDegree = {true;true;true;true;true;false};
        isRotation = true;
    end
    
    mandatory = cellfun(@(x ) [false true(1,x-1)],...
      num2cell(cellfun('prodofsize',fields)),'UniformOutput',false);
    
    switch api.Type
      case 'PoleFigure'
        opts = {'------------------------','Intensity','Background','Defocussing','Defocussing Background'};
        man  = [false,true,false,false,false];
      case 'EBSD'
        opts = {'--- Spatial ------------','x','y','z',...
          '--- Optional ------------','Phase','Weight','ConfidenceIndex','ReliabilityIndex','SemSignal','MAD','BC','Bands'};
        man  = false(size(opts)-[0 2]);
      case 'ODF'
        opts = {'------------------------','Weight'};
        man  = false;
      case 'Orientation'
        opts = {'------------------------','Weight'};
        man  = false;
      otherwise
        opts = {};
        man = logical([]);
    end
    
    fields = cellfun(@(x,y)[{'ignore'} x y],fields,repmat({opts},numel(fields),1),...
      'UniformOutput',false);
    mandatory = cellfun(@(x,y)[false x y],mandatory,repmat({man},numel(fields),1),...
      'UniformOutput',false);
    
    s = struct('name',names,'fields',fields,...
      'mandatory',mandatory,...
      'unit',isDegree,'rotation',isRotation);
    
  end

  function finishCallback(varargin)
    
    colNames = cell(get(gui.hHeaderTable,'data'));
    del = cellfun('isempty',colNames) | strcmpi(colNames,'ignore');
            
    options = {'ColumnNames',colNames(~del)};
    if any(del)
      options = [options,'Columns', {find(~del)}];
    end
    
    if any(strcmpi(api.Type,{'EBSD','ODF'}))
      conventions = {'Bunge','Matthies','Roe','Kocks','Canova','Quaternion'};
      options = [options, conventions{get(gui.hAngleConvention(1),'Value')}];
    end
    
    if strcmpi(get(gui.hAngleConvention(2),'Enable'),'on')
      unit = {[],'Radians'};
      options = [options, unit{get(gui.hAngleConvention(2),'Value')}];
    end
    
    if strcmpi(get(gui.hAngleConvention(3),'Visible'),'on')
      rot  = {[],'Passive Rotation'};
      options = [options rot{get(gui.hAngleConvention(3),'Value')}];
    end
    
    Options = options(~cellfun('isempty',options));
    
    close(api.hFigure);
    
  end

  function enableFinish(b)
    
    set(gui.hFinish,'enable',state{1+b});
    
  end

  function cancelCallback(varargin)
    
    Options = {};
    close(api.hFigure)
    
  end

  function enableHeader(b)
    
    set(gui.hHeader,'Visible',state{1+b});
    
  end

  function headerCallback(varargin)
    
    b = get(gui.hDataTable,'Visible');
    
    set(gui.hDataTable,'Visible',~b)
    set(gui.hHeaderView,'Visible',state{1+b})
    
    mode = {'Show Header','Show Data Table'};
    set(gui.hHeader,'String',mode{1+b})
    
  end

  function localAdjustedScroll(source,event)
    
    val = get(source,'Value');
    
    try
      
      scrollPane1 = get(gui.hDataTable,'TableScrollPane');
      scrollPane2 = get(gui.hHeaderTable,'TableScrollPane');
      s1 = get(scrollPane1,'HorizontalScrollBar');
      s2 = get(scrollPane2,'HorizontalScrollBar');
      
      if get(s1,'Value') ~= val
        set(s1,'Value',val);
        scrollPane1.repaint();
        % scrollPane1.revalidate();
      end
      
      if get(s2,'Value') ~= val
        set(s2,'Value',val);
        scrollPane2.repaint();
        % scrollPane2.revalidate();
      end
      
    catch
      
    end
    
  end

  function gui = localCreateBottomGUIControls()
    
    parent = api.hFigure;
    w    = api.Spacings.Width;
    m    = api.Spacings.Margin;
    
    bW   = api.Spacings.ButtonWidth;
    bH   = api.Spacings.ButtonHeight;
    pH   = api.Spacings.BottomHeight;
    fs   = api.Spacings.FontSize;
    
    pos = @(offset) [offset pH-bH-m bW bH];
    
    % navigation
    cancel = uicontrol(...
      'Parent',parent,...
      'String','Cancel',...
      'FontSize',fs,...
      'Position',pos(w-2*bW-m));
    
    finish = uicontrol(...
      'Parent',parent,...
      'String','Finish',...
      'Enable','off',...
      'FontSize',fs,...
      'Position',pos(w-bW-m));
    
    uipanel(...
      'BorderType','line',...
      'BorderWidth',1,...
      'units','pixel',...
      'parent',parent,...
      'FontSize',fs,...
      'HighlightColor',[0 0 0],...
      'Position',[m pH w-2*m 1]);
    
    gui.hCancel  = cancel;
    gui.hFinish  = finish;
    
  end

  function gui = localCreatePage(gui)
    
    page = api.hPanel;
    w    = api.Spacings.PageWidth;
    h    = api.Spacings.PageHeight;
    m    = api.Spacings.Margin;
    
    bW   = api.Spacings.ButtonWidth;
    bH   = api.Spacings.ButtonHeight;
    pH   = api.Spacings.BottomHeight;
    fs   = api.Spacings.FontSize;
    
    colnames =  api.Columns;
    data     = api.Data;
    
    message1 = {'Please specify the data type of each column! Use the values from the pop up list if possible!'};
    
    message2 = 'The following data matrix was extracted from the file.';
    
    tab = @(x) [
      bH/2
      x   % data table
      bH  %
      65  %  header table
      7/4*bH
      ];
    
    x = floor(fzero(@(x) h-sum(tab(x)+m),0));
    tab = tab(x);
    
    offset = h+m-cumsum(tab+m);
    pos = @(i) [0,offset(i),w,tab(i)];
    
    uicontrol(...
      'Parent',page,....
      'Style','Text',....
      'FontSize',fs,...
      'Position',pos(3)-[0 0 2*bW-m 0],...
      'HorizontalAlignment','left',...
      'String',message1);
    
    if verLessThan('matlab','7.6'), v0 = {}; else v0 = {'v0'}; end
    
    headerTable = uitable(v0{:},...
      'Parent',page,...
      'Data',regexprep(proposedColNames,'Column\d',''),...
      'ColumnNames',colnames,...
      'ColumnWidth',100,...
      'Position',pos(4),...
      'rowheight',bH);
    
    % Euler Angles
    chk_angle = uibuttongroup(...
      'Parent',page,...
      'Title','Angle Convention',...
      'FontSize',fs,...
      'Units','pixels',...
      'Position',pos(5)+[1 0 0 0]);
    
    pop = {codes.name};
    
    ww = [.5 .2 .3]*w-3/2*m;
    ss = cumsum([0 ww(1:end-1)]+m);
    
    cpos = @(i) [ss(i) 0 ww(i) bH];
    
    euler_convention(1) = uicontrol(...
      'Style', 'popup',...
      'String', pop,...
      'FontSize',fs,...
      'BackgroundColor',[1 1 1],...
      'Units','pixels',...
      'Value',proposedConvention,...
      'Position',cpos(1),...
      'Parent',chk_angle);
    
    euler_convention(2) = uicontrol(...
      'Style', 'popup',...
      'String', {'Degree','Radians'},...
      'FontSize',fs,...
      'Units','pixels',...
      'BackgroundColor',[1 1 1],...
      'Position',cpos(2),...
      'Parent',chk_angle);
    
    euler_convention(3) = uicontrol(...
      'Style', 'popup',...
      'String', {'Active Rotation','Passive Rotation'},...
      'FontSize',fs,...
      'Units','pixels',...
      'BackgroundColor',[1 1 1],...
      'Position',cpos(3),...
      'Parent',chk_angle);
    
    uicontrol(...
      'Parent',page,...
      'Style','Text',...
      'Position',pos(1),...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'string',message2);
    
    
    header = uicontrol(...
      'Parent',api.hPanel,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'FontSize',api.Spacings.FontSizeDescription,...
      'HorizontalAlignment','left',...
      'Max',2,...
      'String',api.Header,...
      'Units','pixels',...
      'position',pos(2),...
      'Style','edit',...
      'Enable','inactive');
    
    
    dataTable = uitable(v0{:},...
      'Parent',page,....
      'Data',data(1:end<201,:),...
      'ColumnWidth',100,...
      'ColumnNames',colnames(1:size(data,2)),...
      'Position',pos(2));
    
    
    
    ph = pos(3)-[0 0 2*bW-m 0];
    posH = [ph(3)+m ph(2) 2*bW-2*m bH];
    
    headerButton = uicontrol(...
      'Parent',page,...
      'String','Show Header',...
      'FontSize',fs,...
      'Position',posH,...
      'Visible','on');
    
    gui.hHeader  = headerButton;
    
    gui.hAngleConvention = euler_convention;
    gui.hDataTable       = dataTable;
    gui.hHeaderTable     = headerTable;
    gui.hHeaderView      = header;
    
    try
      dataTable.getTable.setFont(java.awt.Font('sans', 0, 13));
      headerTable.getTable.setFont(java.awt.Font('sans', 0, 13));
      
      hs1 = get(dataTable.getTableScrollPane,'HorizontalScrollBar');
      hs2 = get(headerTable.getTableScrollPane,'HorizontalScrollBar');
      
      set(hs1,'AdjustmentValueChangedCallback',@localAdjustedScroll);
      set(hs2,'AdjustmentValueChangedCallback',@localAdjustedScroll);
    catch
    end
    % input selection
    
    
  end

end



