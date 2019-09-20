function pageSS( api )


setSS = api.Export.setOptSpecimen;
getSS = api.Export.getOptSpecimen;

gui = localCreatePage();

api.setWizardTitle('Specimen Reference Frame')
api.setWizardDescription('Specimen Symmetry')

api.setLeavePageCallback(@leavePage);
api.setGotoPageCallback(@gotoPage);

set(gui.hSCSGroup        ,'SelectionChangeFcn',@localUpdateAxes)
set(gui.hConventionGroup ,'SelectionChangeFcn',@localUpdateAxes)
set(gui.hRotAngle        ,'Callback',@localUpdateAxes)


  function nextPage = leavePage

    %     type = {'PoleFigure','EBSD','ODF','Tensor'};
    slot = api.getDataType();
    type = (mod(slot(1),4)+1);

    switch type
      case 1 % polefigure
        nextPage = @pageMiller;
      case 3 % odf
        nextPage = @pageKernel;
      otherwise
        nextPage = @pageFinish;
    end

  end

  function gotoPage

    api.Progress.enableNext(true);

    localUpdateGUI();

  end

  function localUpdateGUI()

    direction = getSS('direction');

    % set xyz convention
    xaxis = 1 + mod(direction-1,4);
    zaxis = 1 + (direction > 4);
    direction = xaxis + 4*(zaxis-1);

    set(gui.hXYZ(direction),'value',1);
    set(gui.hXYZ(1:8 ~= direction),'value',0);

    states = {'on','off'};
    slots = api.getDataType();
    s = mod((1:2)+((mod(slots(1),4)+1) == 2),2)+1;

    set(gui.hEuler2Spatial,'visible',states{s(1)});
    set(gui.hSpecimen,'visible',states{s(2)});

    [p(1), p(2), p(3)] = Euler(getSS('rotate'),'ZXZ');
    for k=1:3
      set(gui.hRotAngle(k),'String',xnum2str((round(p(k)*1000/degree)/1000)))
    end

    set(gui.hEuler2Spatial,'Value',0);
    set(gui.hEuler2Spatial(getSS('rotOption')),'Value',1);

    if ~isempty(getSS('text'))
      set(gui.hSSText,'String',getSS('text'));
    end

    state = {'on','off'};
    set(gui.hRotate,'Enable',state{1+(getSS('rotOption')>3)})
    set(gui.hRotAngle,'Enable',state{1+(getSS('rotOption')>3)})

  end


  function localUpdateAxes(varargin)

    % get xyz convention
    p = get(gui.hRotAngle,'String');
    p = cellfun(@str2num,p)*degree;
    rot  = rotation.byEuler(p(1),p(2),p(3),'ZXZ');

    setSS('rotate',rot);
    setSS('rotOption',find(cell2mat(get(gui.hEuler2Spatial,'value'))));
    
    direction = find(cell2mat(get(gui.hXYZ,'value')));

    setSS('direction',direction);
    xaxis = 1 + mod(direction-1,4);
    zaxis = 1 + (direction > 4);

    setMTEXpref('xAxisDirection',NWSE(xaxis));
    setMTEXpref('zAxisDirection',UpDown(zaxis));

    % for all axes
    ax = findobj(0,'type','axes');
    fax = [];
    for a = 1:numel(ax)
      if ~isappdata(ax(a),'projection'), continue;end
      setCamera(ax(a),'xAxisDirection',NWSE(xaxis),'zAxisDirection',UpDown(zaxis));
      fax = [fax,ax(a)]; %#ok<AGROW>
    end

    %
    fig = get(fax,'parent');
    if iscell(fig), fig = [fig{:}]; end
    fig = unique(fig);
    for f = 1:numel(fig)
      fn = get(fig(f),'ResizeFcn');
      feval(fn,fig(f),[]);
    end

    localUpdateGUI();

  end

  function [ sym ] = SymmetryList( index )

    sym = [ ...
      {'-1    triclinic'}; ...
      {'112/m   monoclinic'};...
      {'12/m1   monoclinic'};...
      {'2/m11   monoclinic'};...
      {'mmm   orthorhombic'}];

    if nargin > 0
      sym = sym( index );
    end

  end

  function gui = localCreatePage()

    h    = api.Spacings.PageHeight;
    w    = api.Spacings.PageWidth;
    m    = api.Spacings.Margin;
    bH   = api.Spacings.ButtonHeight;
    fs   = api.Spacings.FontSize;

    page = api.hPanel;

    interf = api.Export.getInterface();

    options = {...
      ' apply rotation to Euler angles and spatial coordinates',...
      ' apply rotation only to Euler angles',...
      ' apply rotation only to spatial coordinates',...
      [' use ' upper(interf) ' interface flag ''convertSpatial2EulerReferenceFrame'''],...
      [' use ' upper(interf) ' interface flag ''convertEuler2SpatialReferenceFrame''']};

    if ~any(strcmpi(interf,{'ang','ctf','crc','osc'}))
      options(4:5) = [];
    end

    if api.getDataType() == 1
      hscs = 50+numel(options)*20+m;
    else
      hscs = 75+2*m;
    end

    scs = uibuttongroup('title','Specimen Coordinate System',...
      'Parent',page,...
      'FontSize',fs,...
      'units','pixels','position',[1 h-hscs w hscs]);

    rW = 223;

    specimenText = uicontrol(...
      'Parent',scs,...
      'String','specimen symmetry',...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',[m hscs-2*bH-2*m rW 3/4*20]);

    specimen = uicontrol(...
      'Parent',scs,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'HorizontalAlignment','left',...
      'Position',[m+rW hscs-2*bH-2*m 170 20],...
      'String',blanks(0),...
      'Style','popup',...
      'FontSize',fs,...
      'String',SymmetryList,...
      'Value',1);

    rW = 275+m;

    rotate = uicontrol(...
      'Parent',scs,...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'String','rotate data by Euler angles (Bunge) in degree',...
      'position',[m hscs-bH-2*m rW 3/4*bH]);

    for k=1:3

      rotateAngle(k) = uicontrol(...
        'Parent',scs,...
        'BackgroundColor',[1 1 1],...
        'FontName','monospaced',...
        'FontSize',fs,...
        'HorizontalAlignment','right',...
        'Position',[m+rW+(k-1)*40 hscs-bH-2*m+5 bH 20],...
        'String','0',...
        'Style','edit');

    end



    pos = @(h)  [m hscs-50-h*20 w-2*m 20];

    for k=1:numel(options)

      euler2spatial(k) = uicontrol(...
        'Parent',scs,...
        'Style','radio',...
        'String',options{k},...
        'FontSize',fs,...
        'Value',1,...
        'position',pos(k));

    end

    if numel(euler2spatial) > 3
      set(euler2spatial(4:5),'backgroundcolor',[.9 .9 0.5])
    end

    plotg = uibuttongroup('title','MTEX Plotting Convention',...
      'Parent',page,...
      'units','pixels',...
      'FontSize',fs,...
      'position',[1 h-hscs-80-m w 80]);

    imageNames = {'1xyz','2xyz','3xyz','4xyz','1yxz','4yxz','3yxz','2yxz'};
    for j = 1:8
      xyz(j) = uicontrol(...
        'parent',plotg,...
        'style','togglebutton',...
        'FontSize',fs,...
        'cdata',localLoadPNG([imageNames{j} '.png']),...
        'Position',[5+(j-1)*59 5 54 54]);
    end

    ssText = uicontrol(...
      'String',['Plot ther data to verify that the coordinate' ...
      ' system is properly aligned!'],...
      'Parent',page,...
      'HitTest','off',...
      'Style','text',...
      'FontSize',fs,...
      'HorizontalAlignment','left',...
      'Position',[5 h-hscs-80-18-2*m w-20 18]);

    %     set(ssText,'visible','off')

    gui.hSCSGroup        = scs;
    %     gui.hSpecimenText    = specimenText;
    gui.hSpecimen        = [specimen specimenText];
    gui.hRotAngle        = rotateAngle;
    gui.hRotate          = rotate;
    gui.hEuler2Spatial   = euler2spatial;
    gui.hConventionGroup = plotg;
    gui.hXYZ             = xyz;
    gui.hSSText          = ssText;
    %     gui.hWarning         = euler2spatialText;

  end

  function cdata = localLoadPNG(fname)

    warning('off','MATLAB:imagesci:png:libraryWarning');
    [cdata,map,alpha] = imread(fullfile(mtex_path,'doc','makeDoc','general',fname)); %#ok<ASGLU>
    warning('on','MATLAB:imagesci:png:libraryWarning');
    %cdata = ind2rgb( cdata, map )

    alpha = double(alpha);
    alpha(alpha==0) = NaN;
    cdata = repmat(alpha,[1,1,3]);
    cdata = 1-(cdata+150)./(255+150);
  end

end
