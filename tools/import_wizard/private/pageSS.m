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
    
    [p(1) p(2) p(3)] = Euler(getSS('rotate'),'ZXZ');
    for k=1:3
      set(gui.hRotAngle(k),'String',xnum2str((round(p(k)*1000/degree)/1000)))
    end
    
    set(gui.hEuler2Spatial,'Value',0);
    set(gui.hEuler2Spatial(getSS('rotOption')),'Value',1);
    
    if ~isempty(getSS('text'))
      set(gui.hSSText,'String',getSS('text'));
    end
    
  end


  function localUpdateAxes(varargin)
    
    % get xyz convention
    p = get(gui.hRotAngle,'String');
    p = cellfun(@str2num,p)*degree;
    rot  = rotation('Euler',p(1),p(2),p(3),'ZXZ');
    
    direction = find(cell2mat(get(gui.hXYZ,'value')));
    
    setSS('direction',direction);
    setSS('rotate',rot);
    setSS('rotOption',find(cell2mat(get(gui.hEuler2Spatial,'value'))));
    
    
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
      figure(fig(f));
      feval(fn{:});
    end
    
  end

  function [ sym ] = SymmetryList( index )
    
    sym = [ ...
      {'-1    triclinic'}; ...
      {'2/m   monoclinic'};...
      {'mmm   orthorhombic'}];
    
    if nargin > 0
      sym = sym( index );
    end
    
  end

  function gui = localCreatePage()
    
    h = api.Spacings.PageHeight;
    w = api.Spacings.PageWidth;
    m = api.Spacings.Margin;
    
    page = api.hPanel;
    
    scs = uibuttongroup('title','Specimen Coordinate System',...
      'Parent',page,...
      'units','pixels','position',[1 h-130 w 130]);
    
    specimenText = uicontrol(...
      'Parent',scs,...
      'String','specimen symmetry:',...
      'HitTest','off',...
      'Style','text',...
      'HorizontalAlignment','left',...
      'Position',[10 50  150 15]);
    
    specimen = uicontrol(...
      'Parent',scs,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'HorizontalAlignment','left',...
      'Position',[160 50 170 20],...
      'String',blanks(0),...
      'Style','popup',...
      'String',SymmetryList,...
      'Value',1);
    
    rotate = uicontrol(...
      'Parent',scs,...
      'Style','text',...
      'HorizontalAlignment','left',...
      'String','rotate data by Euler angles (Bunge) in degree',...
      'position',[10 80 300 20]);
    
    rotateAngle(1) = uicontrol(...
      'Parent',scs,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'HorizontalAlignment','right',...
      'Position',[310 80 30 25],...
      'String','0',...
      'Style','edit');
    
    rotateAngle(2) = uicontrol(...
      'Parent',scs,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'HorizontalAlignment','right',...
      'Position',[350 80 30 25],...
      'String','0',...
      'Style','edit');
    
    rotateAngle(3) = uicontrol(...
      'Parent',scs,...
      'BackgroundColor',[1 1 1],...
      'FontName','monospaced',...
      'HorizontalAlignment','right',...
      'Position',[390 80 30 25],...
      'String','0',...
      'Style','edit');
    
    euler2spatial(1) = uicontrol(...
      'Parent',scs,...
      'Style','radio',...
      'String',' apply rotation to Euler angles and spatial coordinates',...
      'Value',1,...
      'position',[10 54 400 20]);
    
    euler2spatial(2) = uicontrol(...
      'Parent',scs,...
      'Style','radio',...
      'String',' apply rotation only to Euler angles',...
      'Value',0,...
      'position',[10 32 400 20]);
    
    euler2spatial(3) = uicontrol(...
      'Parent',scs,...
      'Style','radio',...
      'String',' apply rotation only to spatial coordinates',...
      'Value',0,...
      'position',[10 10 400 20]);
    
%     euler2spatialText = uicontrol(...
%       'Parent',scs,...
%       'Style','text',...
%       'ForeGroundColor','r',...
%       'HorizontalAlignment','left',...
%       'String','',...
%       'Visible','off',...
%       'position',[10 5 400 20]);
    
    %'String',' Warning: This format is known to have incosistent conventions for the Euler angle and the spatial reference',...
    
    plotg = uibuttongroup('title','MTEX Plotting Convention',...
      'Parent',page,...
      'units','pixels',...
      'position',[1 h-130-80-m w 80]);
    
    imageNames = {'1xyz','2xyz','3xyz','4xyz','1yxz','4yxz','3yxz','2yxz'};
    for j = 1:8
      xyz(j) = uicontrol(...
        'parent',plotg,...
        'style','togglebutton',...
        'cdata',localLoadPNG([imageNames{j} '.png']),...
        'Position',[5+(j-1)*59 5 54 54]);
    end
    
    ssText = uicontrol(...
      'String',['Use the "Plot" button to verify that the coordinate' ...
      ' system is properly aligned to the data!'],...
      'Parent',page,...
      'HitTest','off',...
      'Style','text',...
      'HorizontalAlignment','left',...
      'Position',[5 h-130-80-35-2*m w-20 35]);
    
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
    
    [cdata,map,alpha] = imread(fullfile(mtex_path,'help','general',fname)); %#ok<ASGLU>
    %cdata = ind2rgb( cdata, map )
    
    alpha = double(alpha);
    alpha(alpha==0) = NaN;
    cdata = repmat(alpha,[1,1,3]);
    cdata = 1-(cdata+150)./(255+150);
  end

end


