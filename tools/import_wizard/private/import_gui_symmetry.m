function handles = import_gui_symmetry( handles, varargin )

pos = get(handles.wzrd,'Position');
h = pos(4);
w = pos(3);

ph = 270;

type = get_option(varargin,'type');

%% crystal system
handles.page2 = get_panel(w,h,ph);


cs = uibuttongroup('title','Crystal Coordinate System',...
  'Parent',handles.page2,...
  'units','pixels','position',[0 ph-160 380 150]);

uicontrol(...
 'Parent',cs,...
  'String','Laue Group',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 95 100 15]);

handles.crystal = uicontrol(...
'Parent',cs,...
'BackgroundColor',[1 1 1],... 
'FontName','monospaced',...
'HorizontalAlignment','left',...
'Position',[105 95 260 20],...
'String',blanks(0),...
'Style','popup',...
'CallBack',['import_wizard_' type '(''updatecrystal'')'],...
'String',symmetries,...
'Value',1);

uicontrol(...
  'Parent',cs,...
  'String','Axis Length',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 55 100 15]);
uicontrol(...
  'Parent',cs,...
  'String','Axis Angle',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 20 100 15]);

axis = {'a','b','c'};
angle=  {'alpha', 'beta', 'gamma'};
for k=1:3
  uicontrol(...
    'Parent',cs,...
    'String',axis{k},...
    'HitTest','off',...
    'Style','text',...
    'HorizontalAlignment','right',...
    'Position',[120+90*(k-1) 55 20 15]);
  uicontrol(...
    'Parent',cs,...
    'String',angle{k},...
    'HitTest','off',...
    'Style','text',...
    'HorizontalAlignment','right',...
    'Position',[100+90*(k-1) 20 40 15]);
  handles.axis{k} = uicontrol(...
    'Parent',cs,...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Position',[145+90*(k-1) 50 40 25],...
    'String',blanks(0),...
    'Style','edit');
  handles.angle{k} = uicontrol(...
    'Parent',cs,...
    'BackgroundColor',[1 1 1],...
    'FontName','monospaced',...
    'HorizontalAlignment','left',...
    'Position',[145+90*(k-1) 15 40 25],...
    'String',blanks(0),...
    'Style','edit');
end



ss = uibuttongroup('title','Specimen Coordinate System',...
  'Parent',handles.page2,...
  'units','pixels','position',[0 ph-260 380 75]);

uicontrol(...
 'Parent',ss,...
  'String','Laue Group',...
  'HitTest','off',...
  'Style','text',...
  'HorizontalAlignment','left',...
  'Position',[10 20  100 15]);

handles.specime = uicontrol(...
'Parent',ss,...
'BackgroundColor',[1 1 1],...
'FontName','monospaced',...
'HorizontalAlignment','left',...
'Position',[100 20 260 20],...
'String',blanks(0),...
'Style','popup',...
'String',symmetries,...
'Value',1);


