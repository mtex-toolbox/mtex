function laprint(figno,filename,varargin)
%LAPRINT prints a figure for inclusion in LaTeX documents.
%  LaPrint creates an eps-file and a tex-file. The tex-file contains
%  the annotation of the figure such as titles, labels and texts. The
%  eps-file contains the non-text part of the figure as well as the 
%  position of the text-objects. The packages 'graphicx' (or 'epsfig')
%  and 'psfrag' (and possibly ''color'') are required for the LaTeX 
%  run. A postscript driver like 'dvips' is required for printing. 
%
%% Syntax
%  >> laprint
%
%  This opens a graphical user interface window, to control the
%  various settings. It includes a help facility. Just try it.
%
%  As an alternative to the GUI you can call laprint from the command
%  line with various extra input arguments. These arguments are 
%  explained in the help window of the GUI, which can be also be 
%  opened using the command
%  >> laprint helpwindow
%
%  There is an Users Guide available at
%  http://www.uni-kassel.de/fb16/rat/matlab/laprint/laprintdoc.ps  

%  (c) Arno Linnemann.   All rights reserved. 
%  The author of this program assumes no responsibility for any  errors 
%  or omissions. In no event shall he be liable for damages  arising out of 
%  any use of the software. Redistribution of the unchanged file is allowed.
%  Distribution of changed versions is allowed provided the file is renamed
%  and the source and authorship of the original version is acknowledged in 
%  the modified file.

%  Please report bugs, suggestions and comments to:
%  Arno Linnemann
%  Control and Automation
%  Department of Electrical and Computer Engineering 
%  University of Kassel
%  34109 Kassel
%  Germany
%  mailto:linnemann@uni-kassel.de

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Initialize
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

laprintident = '3.16 (13.9.2004)';   
vers = version;
vers = eval(vers(1:3));
if vers < 6.1
  error('Sorry. Matlab 6.1 or above is required.')
end

hf=131;
hhf=132;

% no output
if nargout
   error('No output argument, please.')
end  

inter=get(0,'defaulttextinterpreter');
if ~strcmp(inter,'none')
  warning('LaPrint:general',['It is recommended to switch off the '...
          'text interpreter\nbefore creating a figure to be saved '...
          'with LaPrint. Use the command\n',...
          '   >> set(0,''defaulttextinterpreter'',''none'').'])
end

if nargin==0

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%
   %%%% GUI
   %%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   try
     delete(hf) 
   end 
   try
     delete(hhf) 
   end 

   %---------------------------------
   % open window
   %---------------------------------

   hf = figure(hf);
   clf reset;
   set(hf,'NumberTitle','off',...
          'Name','LaPrint (LaTeX Print)',...
          'Units','points',...
          'CloseRequestFcn','laprint(''quit'');',...
          'menubar','none')
   h = uicontrol('Parent',hf,'Units','points');
   fsize = get(h,'Fontsize');
   delete(h)
   posf = get(hf,'Position');
   figheight = 10*fsize;
   figwidth  = 32*fsize; 
   posf = [ posf(1) posf(2)+posf(4)-figheight figwidth figheight];
   set(hf,'Position',posf)
   uicontrol('Parent',hf,'style','frame','Units','points',...
	  'Position',[0 0 figwidth figheight])
   curh = figheight-0*fsize;

   LAPRINTHAN=struct('figno',{0},'filename',{0},...
      'keepfontprops',{0},'asonscreen',{0},'keepticklabels',{0},...
      'mathticklabels',{0},'head',{0},'extrapicture',{0},...
      'verbose',{0},'figcopy',{0},'package_epsfig',{0},...
      'package_graphicx',{0},'color',{0},'createview',{0},...
      'processview',{0});
  
   %---------------------------------
   % figure no.
   %---------------------------------

   loch = 1.7*fsize;
   curh = curh-loch-1.5*fsize;
   h = uicontrol('Parent',hf,...
                 'style','text',...
                 'Units','points',...
                 'Position',[1*fsize curh 18*fsize loch],...
                 'HorizontalAlignment','left',...
                 'string','Number of Figure to be saved:');
   h = uicontrol('Parent',hf,...
                 'style','edit',...
                 'Units','points',...
                 'Position',[19*fsize curh 12*fsize loch],...
                 'HorizontalAlignment','left',...
                 'BackgroundColor',[1 1 1],...
                 'Callback','laprint(''figno'');');
   LAPRINTHAN.figno = h;

   %---------------------------------
   % filename
   %---------------------------------

   loch = 1.7*fsize;
   curh = curh-loch-1*fsize;
   h = uicontrol('Parent',hf,...
                 'style','text',...
                 'Units','points',...
                 'Position',[1*fsize curh 18*fsize loch],...
                 'HorizontalAlignment','left',...
                 'string','Basename of Files to be Created:');
   h = uicontrol('Parent',hf,...
                 'style','edit',...
                 'Units','points',...
                 'Position',[19*fsize curh 12*fsize loch],...
                 'HorizontalAlignment','left',...
                 'BackgroundColor',[1 1 1],...
                 'Callback','laprint(''filename'');');
   LAPRINTHAN.filename = h;

   %---------------------------------
   % save, quit
   %---------------------------------

   loch = 2*fsize;
   curh = curh-loch-1*fsize;
   h = uicontrol('Parent',hf,...
                 'Style','pushbutton',...
                 'Units','Points',...
                 'Position',[19*fsize curh 5*fsize loch],...
                 'HorizontalAlignment','center',...
                 'String','Go !',...
                 'Callback','laprint(''save'');');
   h = uicontrol('Parent',hf,...
                 'Style','pushbutton',...
                 'Units','Points',...
                 'Position',[26*fsize curh 5*fsize loch],...
                 'HorizontalAlignment','center',...
                 'String','Quit',...
                 'Callback','laprint(''quit'');');

   %---------------------------------
%% Options
% uimenue
   %---------------------------------

   hm1 = uimenu('label','Options');

   uimenu(hm1,...
       'label','Sizes and Scalings ...',...
       'callback','laprint(''size'')');

   LAPRINTHAN.keepfontprops = uimenu(hm1,...
       'label','Translate Matlab Font Properties to LaTeX',...
       'callback','laprint(''keepfontprops'')');

   LAPRINTHAN.asonscreen = uimenu(hm1,...
       'label','Print Limits and Ticks as on Screen',...
       'separator','on',...
       'callback','laprint(''asonscreen'')');

   LAPRINTHAN.keepticklabels = uimenu(hm1,...
       'label','Keep Tick Labels within eps File',...
       'callback','laprint(''keepticklabels'')');

   LAPRINTHAN.mathticklabels = uimenu(hm1,...
       'label','Set Tick Labels in LaTeX Math Mode',...
       'callback','laprint(''mathticklabels'')');

   LAPRINTHAN.head = uimenu(hm1,...
       'label','Equip the tex File with a Head',...
       'separator','on',...
       'callback','laprint(''head'')');

   uimenu(hm1,...
       'label','Comment in the Head of the tex File ...',...
       'callback','laprint(''comment'')');

   uimenu(hm1,...
       'label','Place a LaTeX Caption in the tex File ...',...
       'callback','laprint(''caption'')');

   LAPRINTHAN.extrapicture = uimenu(hm1,...
       'label','Place an Extra Picture in each Axes',...
       'callback','laprint(''extrapicture'')');

   uimenu(hm1,...
       'label','Length of psfrag Replacement Strings ...',...
       'callback','laprint(''nzeros'')');

   LAPRINTHAN.verbose = uimenu(hm1,...
       'label','Call LaPrint in Verbose Mode',...
       'separator','on',...
       'callback','laprint(''verbose'')');

   LAPRINTHAN.figcopy = uimenu(hm1,...
       'label','Copy Figure and Modify that Copy',...
       'callback','laprint(''figcopy'')');

   uimenu(hm1,...
       'label','Matlab Print Command ...',...
       'separator','on',...
       'callback','laprint(''printcmd'')');

   h=uimenu(hm1,...
       'separator','on',...
       'label','LaTeX Graphics Package');
   
   LAPRINTHAN.package_graphicx = uimenu(h,...
       'label','graphicx',...
       'callback','laprint(''package_graphicx'')');
   
   LAPRINTHAN.package_epsfig = uimenu(h,...
       'label','epsfig',...
       'callback','laprint(''package_epsfig'')');
     
   LAPRINTHAN.color = uimenu(hm1,...
       'label','Use LaTeX ''color'' Package',...
       'callback','laprint(''color'')');
  
   h = uimenu(hm1,...
       'label','View File ...',...
       'separator','on');
 
   LAPRINTHAN.createview = uimenu(h,...
       'label','Create a View File',...
       'callback','laprint(''createview'')');
  
   uimenu(h,...
       'label','Name of the View File ...',...
       'callback','laprint(''viewfilename'')');

   LAPRINTHAN.processview = uimenu(h,...
       'label','Process the View File',...
       'separator','on',...
       'callback','laprint(''processview'')');

   uimenu(h,...
       'label','Executables for Processing View File...',...
       'callback','laprint(''cmdsview'')');

   %---------------------------------
   % Preferences uimenue
   %---------------------------------
     
   hm3=uimenu('label','Preferences');
     
   uimenu(hm3,...
       'label','Get Preferences',...
       'callback','laprint(''getpref'')')
   
   uimenu(hm3,...
       'label','Set Preferences to Current Settings',...
       'callback','laprint(''setpref'')')
   
   uimenu(hm3,...
       'label','Remove Preferences',...
       'callback','laprint(''rmpref'')')
   
   uimenu(hm3,...
       'label','Save Current Settings to a File ...',...
       'separator','on',...
       'callback','laprint(''savepref'')')
   
   uimenu(hm3,...
       'label','Load Settings from a File ...',...
       'callback','laprint(''loadpref'')')
   
   uimenu(hm3,...
       'label','Get Factory Defaults',...
       'separator','on',...
       'callback','laprint(''factory'')')

  
   %---------------------------------
   % Help uimenue
   %---------------------------------
   
   hm2=uimenu('label','Help');
   
   uimenu(hm2,...
       'label',['LaPrint Online Help ...'],...
       'callback','laprint(''helpwindow'')');
  
   uimenu(hm2,...
       'label','Get the LaPrint Users Guide',...
       'callback',['web www.uni-kassel.de/fb16/rat/matlab',...
                   '/laprint/laprintdoc.ps -browser'])
    
   uimenu(hm2,...
       'label',['Look for a newer version of LaPrint ' ...
           '(Matlab Central File Exchange)...'],...
       'callback',['web http://www.mathworks.de/matlabcentral/',...
                      'fileexchange/loadFile.do?objectId=4638',...
                      '&objectType=file -browser'])
    
   uimenu(hm2,...
       'label','Version and Author ...',...
       'callback','laprint(''whois'')')

   %---------------------------------
   % make hf invisible
   %---------------------------------

   set(hf,'HandleVisibility','callback') 

   %---------------------------------
   % get settings
   %---------------------------------
 
   LAPRINTOPT = prefsettings;
   if isempty(LAPRINTOPT)
      LAPRINTOPT = factorysettings;
   end  

   %---------------------------------
   % get figure
   %---------------------------------
    
   gcfig=gcf;
   if gcfig == hf
       allfigs = findobj('type','figure');
       allfigs = allfigs(find(allfigs~=hf));
       if length(allfigs)
          figno = allfigs(1);
       else
          figure(1)
          figno=1;
       end    
   else
       figno=gcfig;
   end
   LAPRINTOPT.figno = figno;

   %---------------------------------
   % update
   %---------------------------------
  
   updategui(LAPRINTHAN,LAPRINTOPT)
   sethf(hf,LAPRINTHAN,LAPRINTOPT)
   figure(hf)

   %---------------------------------
   % done
   %---------------------------------

   return
   
end  % if nargin==0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% callback calls ('factory' and 'getprefs' also 
%%%%  used from command line)
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isa(figno,'char') 

  switch figno
  case 'figno'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    LAPRINTOPT.figno=eval(get(LAPRINTHAN.figno,'string'));
    figure(LAPRINTOPT.figno)
    figure(hf)
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'filename'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    LAPRINTOPT.filename=get(LAPRINTHAN.filename,'string');
    [texfullnameext,texbasenameext,texbasename,texdirname] = ...
	getfilenames(LAPRINTOPT.filename,'tex',0);
    [epsfullnameext,epsbasenameext,epsbasename,epsdirname] = ...
	getfilenames(LAPRINTOPT.filename,'eps',0);
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'save'
%  lapcmd = [ 'laprint(' int2str(LAPRINTOPT.figno) ...
%  ', ''' LAPRINTOPT.filename ''''...
%  ', ''options'', LAPRINTOPT)'];
    lapcmd = 'laprint({})';
    eval(lapcmd)
  case 'quit'
    delete(hf)
    try
      delete(hhf)
    end
  case 'size'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    answer = inputdlg({['Please enter the width (in centimeters) ',...
         'of the graphics in the LaTeX document (The height ',...
         'will be computed such that the aspect ratio of the ',...
         'figure on screen is retained.) :'],...
         ['Please enter the factor by which the size of the '...
         'graphics in the LaTeX document differs from the size of the '...
         'Postscipt graphics ( Explaination: A factor <1 scales ',...
         'the picture down. This means that lines become thinner ',...
         'and fonts become smaller. ) :'],...
         ['Please specify if you want to scale the fonts along with ',...
         'the graphics (enter ''on'' or ''off'') : '] },...
         'LaPrint Settings',1,{num2str(LAPRINTOPT.width),...
         num2str(LAPRINTOPT.factor),...
         valueyn(LAPRINTOPT.scalefonts)},'on');
    if length(answer)
         LAPRINTOPT.width=eval(answer{1});
         LAPRINTOPT.factor = eval(answer{2});
         LAPRINTOPT.scalefonts = value01(answer{3});
    end
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'keepfontprops'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.keepfontprops==1
      LAPRINTOPT.keepfontprops=0;
      set(LAPRINTHAN.keepfontprops,'check','off')
    else
      LAPRINTOPT.keepfontprops=1;
      set(LAPRINTHAN.keepfontprops,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'asonscreen'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.asonscreen==1
      LAPRINTOPT.asonscreen=0;
      set(LAPRINTHAN.asonscreen,'check','off')
    else
      LAPRINTOPT.asonscreen=1;
      set(LAPRINTHAN.asonscreen,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'keepticklabels'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.keepticklabels==1
      LAPRINTOPT.keepticklabels=0;
      set(LAPRINTHAN.keepticklabels,'check','off')
    else
      LAPRINTOPT.keepticklabels=1;
      set(LAPRINTHAN.keepticklabels,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'mathticklabels'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.mathticklabels==1
      LAPRINTOPT.mathticklabels=0;
      set(LAPRINTHAN.mathticklabels,'check','off')
    else
      LAPRINTOPT.mathticklabels=1;
      set(LAPRINTHAN.mathticklabels,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'head'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.head==1
      LAPRINTOPT.head=0;
      set(LAPRINTHAN.head,'check','off')
    else
      LAPRINTOPT.head=1;
      set(LAPRINTHAN.head,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'comment'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    answer = inputdlg({['Please enter a describing comment to '...
         'be placed into the head of the tex file:']},...
         'LaPrint Settings',1,{LAPRINTOPT.comment},'on');
    if length(answer)
         LAPRINTOPT.comment = answer{1};
    end
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'caption'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    answer = inputdlg(['If the following text is nonempty, ' ...
         'then it will be placed as a \caption{} into the tex '...
         'file along with \label{fig:' LAPRINTOPT.filename '}. '...
         'Please enter the caption text:'],...
         'LaPrint Settings',1,{LAPRINTOPT.caption},'on');
    if length(answer)
         LAPRINTOPT.caption = answer{1};
    end
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'extrapicture'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.extrapicture==1
      LAPRINTOPT.extrapicture=0;
      set(LAPRINTHAN.extrapicture,'check','off')
    else
      LAPRINTOPT.extrapicture=1;
      set(LAPRINTHAN.extrapicture,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'nzeros'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    answer = inputdlg({['Please enter length of the psfrag replacement '...
         'strings (must be >= 3) :']},...
         'LaPrint Settings',1,{num2str(LAPRINTOPT.nzeros)},'on');
    if length(answer)
        LAPRINTOPT.nzeros = max(eval(answer{1}),3);
    end
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'verbose'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.verbose==1
      LAPRINTOPT.verbose=0;
      set(LAPRINTHAN.verbose,'check','off')
    else
      LAPRINTOPT.verbose=1;
      set(LAPRINTHAN.verbose,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'figcopy'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.figcopy==1
      LAPRINTOPT.figcopy=0;
      set(LAPRINTHAN.figcopy,'check','off')
    else
      LAPRINTOPT.figcopy=1;
      set(LAPRINTHAN.figcopy,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'printcmd'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    answer = inputdlg({['Please enter the Matlab command '...
         'to be used for printing the eps file '...
         '(LaPrint will internally replace <figurenumber> by the '...
         'number of the figure <filename.eps> by the ' ... 
         'eps-filename and <filename> '...
         'by the basename of the file, respectively). You can add options '...
         'here (like ''-loose'') or use a different program '...
         'for printing (like ''exportfig'') :']},...
         'LaPrint Settings',1,{LAPRINTOPT.printcmd},'on');
    if length(answer)
         LAPRINTOPT.printcmd = answer{1};
    end
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'package_epsfig'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    LAPRINTOPT.package='epsfig';
    set(LAPRINTHAN.package_epsfig,'check','on')
    set(LAPRINTHAN.package_graphicx,'check','off')
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'package_graphicx'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    LAPRINTOPT.package='graphicx';
    set(LAPRINTHAN.package_epsfig,'check','off')
    set(LAPRINTHAN.package_graphicx,'check','on')
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'color'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.color==1
      LAPRINTOPT.color=0;
      set(LAPRINTHAN.color,'check','off')
    else
      LAPRINTOPT.color=1;
      set(LAPRINTHAN.color,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'createview'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.createview==1
      LAPRINTOPT.createview=0;
      LAPRINTOPT.processview=0;
      set(LAPRINTHAN.createview,'check','off')
      set(LAPRINTHAN.processview,'check','off')
    else
      LAPRINTOPT.createview=1;
      set(LAPRINTHAN.createview,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'viewfilename'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
      trydlg=1;
      txt=['Please enter the name of the '...
          'viewfile (without extension .tex) : '];
      txt2='';
      while trydlg
        answer = inputdlg({[txt txt2]},...
          'LaPrint Settings',1,{LAPRINTOPT.viewfilename},'on');
        if length(answer)
          if strcmp(answer{1},LAPRINTOPT.filename)
            txt2=['The name must be different from the name of the '...
                  'graphics file):'];
          else
             trydlg=0;  
             LAPRINTOPT.viewfilename = answer{1};
             [viewfullnameext,viewbasenameext,viewbasename,viewdirname] = ...
  	                getfilenames(LAPRINTOPT.viewfilename,'tex',0);
         end      
        else
          trydlg=0;
        end  
      end
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'processview'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    if LAPRINTOPT.processview==1
      LAPRINTOPT.processview=0;
      set(LAPRINTHAN.processview,'check','off')
    else
      LAPRINTOPT.processview=1;
      set(LAPRINTHAN.processview,'check','on')
      LAPRINTOPT.createview=1;
      set(LAPRINTHAN.createview,'check','on')
    end      
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'cmdsview'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    answer = inputdlg({...
       ['Please enter up to 8 commands to process the view-file. ',...
       'Leave any of the fields empty, if you have ',...
       'less than 8 commands. ',...  
       'In any of the following commands, LaPrint internally '...
       'replaces the tag <viewfile> by the name of the viewfile ',...
       'and the tag <filename> by the basename specified in the ',...
       'main LaPrint Window. ',...
       'At minimum you should enter the commands for the LaTeX ',...
       'compilation and for the dvi-to-postscript conversion ',...
       'here. See the LaPrint Online-Help for futher ',...
       'suggestions.   ',...
       'Please enter the 1st command:'],...
       'Please enter the 2nd command:',...
       'Please enter the 3rd command:',...
       'Please enter the 4th command:',...
       'Please enter the 5th command:',...
       'Please enter the 6th command:',...
       'Please enter the 7th command:',...
       'Please enter the 8th command:'},...
       'LaPrint Settings',1,{LAPRINTOPT.cmd1,...
       LAPRINTOPT.cmd2,LAPRINTOPT.cmd3,...
       LAPRINTOPT.cmd4,LAPRINTOPT.cmd5,LAPRINTOPT.cmd6,...
       LAPRINTOPT.cmd7,LAPRINTOPT.cmd8},'on');
    if length(answer)==8
       LAPRINTOPT.cmd1=answer{1};
       LAPRINTOPT.cmd2=answer{2};
       LAPRINTOPT.cmd3=answer{3};
       LAPRINTOPT.cmd4=answer{4};
       LAPRINTOPT.cmd5=answer{5};
       LAPRINTOPT.cmd6=answer{6};
       LAPRINTOPT.cmd7=answer{7};
       LAPRINTOPT.cmd8=answer{8};
    end   
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'getpref'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    out = prefsettings;
    if ~isempty(out)
       oldfigno = LAPRINTOPT.figno;   % keep this!         
       LAPRINTOPT = out;
       LAPRINTOPT.figno = oldfigno;        
    else
       errordlg('No LaPrint preferences available.')   
    end
    updategui(LAPRINTHAN,LAPRINTOPT);
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'setpref'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    setpref('LaPrint','LAPRINTOPT',LAPRINTOPT);
  case 'rmpref'
    if ispref('LaPrint')
      rmpref('LaPrint');
    else
      errordlg('Preference does not exist.')   
    end
  case 'savepref'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    txt = 'Save preferences file ';
    [preffile,prefpath]=uiputfile('laprint.mat',txt);
    save([prefpath preffile],'LAPRINTOPT');
  case 'loadpref'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    txt = ['Load preferences file '...
           '(must be previously created by LaPrint)'];
    [preffile,prefpath]=uigetfile('laprint.mat',txt);
    if ~isequal(preffile,0) & ~isequal(prefpath,0)
      oldfigno = LAPRINTOPT.figno;   % keep this!         
      load([prefpath preffile]); % hope file contains correct
      LAPRINTOPT.figno = oldfigno;                   % LAPRINTOPT
      updategui(LAPRINTHAN,LAPRINTOPT);
      sethf(hf,LAPRINTHAN,LAPRINTOPT);
    end
  case 'factory'
    [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
    out = factorysettings;
    if ~isempty(out)
       oldfigno = LAPRINTOPT.figno;   % keep this!         
       LAPRINTOPT = out;
       LAPRINTOPT.figno = oldfigno;        
    else
       errordlg('No LaPrint preferences available.')   
    end
    updategui(LAPRINTHAN,LAPRINTOPT);
    sethf(hf,LAPRINTHAN,LAPRINTOPT);
  case 'helpwindow'
    hhf=figure(hhf);
    set(hhf,'Name','LaPrint Online Help',...
            'Numbertitle','off',...
            'menubar','none',...
            'HandleVisibility','callback',... 
            'resize','on',...
            'ResizeFcn','laprint(''helpwindow'');');
    hht=uicontrol('Parent',hhf,...
              'style','listbox',...
              'units','normalized',...
              'position',[0.005 0.005 0.9 0.99],...
              'BackgroundColor','w',...
              'Fontsize',12,...
              'foregroundcolor','k',...
              'FontName','FixedWidth',...
              'HorizontalAlignment','left');
    [txt,hhtpos]=textwrap(hht,helptext);
    set(hht,'string',txt)
    set(hht,'position',[0.005 0.005 0.99 0.99])
    set(hht,'HandleVisibility','callback') 
  case 'whois'
    msgbox({['This is LaPrint, Version ' laprintident],...
          '',...
          'To blame for LaPrint:',...
	      'Arno Linnemann','Control and Automation',...
	      'Department of Electrical and Computer Engineering',...
	      'University of Kassel',...
	      '34109 Kassel',...      
	      'Germany',...
          'mailto:linnemann@uni-kassel.de'},...
          'LaPrint Info')
  otherwise 
    error('unknown callback option')
  end
  return 
end    % if isa(figno,'char') 

% nargin >=1 and ~isa(figno,'char')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% PART 1 of advanced Syntax:
%%%% Check inputs and initialize
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isa(figno,'cell') % called from GUI (all set)

  [LAPRINTHAN,LAPRINTOPT]=gethf(hf);
  figno=LAPRINTOPT.figno;
  filename=LAPRINTOPT.filename;

else % advanced Syntax
  
  % get settings 
  LAPRINTOPT = prefsettings;
  if isempty(LAPRINTOPT)
     LAPRINTOPT = factorysettings;
  end

  % modify prefs
  if ~isa(figno,'double') 
    figno
    error('This is not a figure handle.') 
  end
  if ~any(get(0,'children')==figno)
    figno
    error('This is not a figure handle.') 
  end
  LAPRINTOPT.figno = figno;

  if nargin>1
    if ~isa(filename,'char')  
      filename
      error('This is not a file name.') 
    end
    LAPRINTOPT.filename=filename; 
  end    
end

% read and check command line options  

try  % try old Syntax (Version 2.03)
   if nargin <=2
      error('lets take new Syntax')
   end
   % 2.03 defaults
   width           = 12;
   factor          = 0.8;
   scalefonts      = 1;
   keepfontprops   = 0;
   asonscreen      = 0;
   keepticklabels  = 0;
   mathticklabels  = 0;
   head            = 1;
   comment         = '';
   caption         = '';
   extrapicture    = 1;
   nzeros          = 5;
   verbose         = 0;
   figcopy         = 1;
   printcmd        = ['print(''-f<figurenumber>'',' ...
                      '''-deps'',''<filename.eps>'')'];
   package         = 'epsfig';
   color           = 0;
   createview      = 0;
   viewfilename    = [filename '_'];
   processview     = 0;
   cmd1            = '';
   cmd2            = '';
   cmd3            = '';
   cmd4            = '';
   cmd5            = '';
   cmd6            = '';
   cmd7            = '';
   cmd8            = '';
   for i=1:nargin-2
    if ~isa(varargin{i},'char')
      error('Options must be character arrays.')
    end  
    oriopt=varargin{i}(:)';
    opt=[ lower(strrep(oriopt,' ','')) '                   ' ];
    if strcmp(opt(1:7),'verbose')
      verbose=1;
    elseif strcmp(opt(1:10),'asonscreen')
      asonscreen=1;
    elseif strcmp(opt(1:14),'keepticklabels')
      keepticklabels=1;
    elseif strcmp(opt(1:14),'mathticklabels')
      mathticklabels=1;
    elseif strcmp(opt(1:13),'keepfontprops')
      keepfontprops=1;
    elseif strcmp(opt(1:14),'noextrapicture')
      extrapicture=0;
    elseif strcmp(opt(1:14),'noextrapicture')
      extrapicture=0;
    elseif strcmp(opt(1:5),'loose')
      printcmd = ['print(''-f<figurenumber>'',' ...
                      '''-deps'',''-loose'',''<filename.eps>'')'];
    elseif strcmp(opt(1:9),'nofigcopy')
      figcopy=0;
    elseif strcmp(opt(1:12),'noscalefonts')
      scalefonts=0;
    elseif strcmp(opt(1:6),'nohead')
      head=0;
    elseif strcmp(opt(1:7),'caption')
      eqpos=findstr(oriopt,'=');
      if isempty(eqpos)
	    caption='Matlab Figure';
      else	
	    caption=oriopt(eqpos+1:length(oriopt));
      end	
    elseif strcmp(opt(1:8),'comment=')
      eqpos=findstr(oriopt,'=');
      comment=oriopt(eqpos(1)+1:length(oriopt));
    elseif strcmp(opt(1:9),'viewfile=')
      createview=1;
      eqpos=findstr(oriopt,'=');
      viewfilename=oriopt(eqpos(1)+1:length(oriopt));
    elseif strcmp(opt(1:6),'width=')
      eval([ opt ';' ]);
    elseif strcmp(opt(1:7),'factor=')
      eval([ opt ';' ]);
    else
      error([ 'Option ' varargin{i} ' not recognized.'])
    end   
  end
 
  warning('LaPrint:general',['You are using the old LaPrint '...
          'syntax. This syntax might not be supported in '...
          'future releases of LaPrint.'])

catch % old Syntax doesn't work, take new one
  
  % restore preferences / factory defaults
  width           = LAPRINTOPT.width;
  factor          = LAPRINTOPT.factor;
  scalefonts      = LAPRINTOPT.scalefonts;
  keepfontprops   = LAPRINTOPT.keepfontprops;
  asonscreen      = LAPRINTOPT.asonscreen;
  keepticklabels  = LAPRINTOPT.keepticklabels;
  mathticklabels  = LAPRINTOPT.mathticklabels;
  head            = LAPRINTOPT.head;
  comment         = LAPRINTOPT.comment;
  caption         = LAPRINTOPT.caption;
  extrapicture    = LAPRINTOPT.extrapicture;
  nzeros          = LAPRINTOPT.nzeros;
  verbose         = LAPRINTOPT.verbose;
  figcopy         = LAPRINTOPT.figcopy;
  printcmd        = LAPRINTOPT.printcmd;
  package         = LAPRINTOPT.package;
  color           = LAPRINTOPT.color;
  createview      = LAPRINTOPT.createview;
  viewfilename    = LAPRINTOPT.viewfilename;
  processview     = LAPRINTOPT.processview;
  cmd1            = LAPRINTOPT.cmd1;
  cmd2            = LAPRINTOPT.cmd2;
  cmd3            = LAPRINTOPT.cmd3;
  cmd4            = LAPRINTOPT.cmd4;
  cmd5            = LAPRINTOPT.cmd5;
  cmd6            = LAPRINTOPT.cmd6;
  cmd7            = LAPRINTOPT.cmd7;
  cmd8            = LAPRINTOPT.cmd8;

  if nargin > 2
    if rem(nargin,2)
      error('Option names/values must appear in pairs.')
    end    
    for i=1:2:nargin-2
      if ~isa(varargin{i},'char')
         error('Option name must be a character array.')
      end  
      opt = lower(strrep(varargin{i}(:)',' ',''));
      val = varargin{i+1}(:)';
      switch opt
        case 'options'      
          if isa(val,'char')
            if strcmp(val,'factory')
              val = factorysettings;
            else
              load(val)
              val = LAPRINTOPT;
            end
          end
          if ~isa(val,'struct')
            error('Value of options must be a structure array.')
          end  
          % no error checking here!
          width           = val.width;
          factor          = val.factor;
          scalefonts      = val.scalefonts;
          keepfontprops   = val.keepfontprops;
          asonscreen      = val.asonscreen;
          keepticklabels  = val.keepticklabels;
          mathticklabels  = val.mathticklabels;
          head            = val.head;
          comment         = val.comment;
          caption         = val.caption;
          extrapicture    = val.extrapicture;
          nzeros          = val.nzeros;
          verbose         = val.verbose;
          figcopy         = val.figcopy;
          printcmd        = val.printcmd;
          package         = val.package;
          color           = val.color;
          createview      = val.createview;
          viewfilename    = val.viewfilename;
          processview     = val.processview;
          cmd1            = val.cmd1;
          cmd2            = val.cmd2;
          cmd3            = val.cmd3;
          cmd4            = val.cmd4;
          cmd5            = val.cmd5;
          cmd6            = val.cmd6;
          cmd7            = val.cmd7;
          cmd8            = val.cmd8;
        case 'width'     
          if ~isa(val,'double')  
            error('Value of width must be a double.')
          end  
          width = val;  
        case 'factor'     
          if ~isa(val,'double')  
            error('Value of factor must be a double.')
          end  
          factor=val;  
        case 'scalefonts'
          scalefonts = value01(val,opt); 
        case 'keepfontprops'
          keepfontprops = value01(val,opt); 
        case 'asonscreen'     
          asonscreen = value01(val,opt);
        case 'keepticklabels'
          keepticklabels = value01(val,opt); 
        case 'mathticklabels'
          mathticklabels = value01(val,opt) ;
        case 'head'
          head = value01(val,opt); 
        case 'comment'
          if ~isa(val,'char')
            error('Value of comment must be a character array.')
          end
          comment = val;
        case 'caption'
          if ~isa(val,'char')
            error('Value of caption must be a character array.')
          end
          caption = val;
        case 'extrapicture'
          extrapicture = value01(val,opt); 
        case 'nzeros'     
          if ~isa(val,'double')  
            error('Value of nzeros must be a double.')
          end  
          nzeros = val;
        case 'verbose'
          verbose = value01(val,opt);
        case 'figcopy'
          figcopy = value01(val,opt); 
        case 'printcmd'
          if ~isa(val,'char')
            error('Value of printcmd must be a character array.')
          end
          printcmd = val;
        case 'package'
          if ~isa(val,'char')
            error('Value of package must be a character array.')
          end
          val = lower(strrep(val,' ',''));
          switch val
            case {'graphicx','epsfig'}
              % fine
            otherwise
              error('Value of package is unknown.')
          end  
          package = val;
        case 'color'
          color = value01(val,opt); 
        case 'createview'
          createview = value01(val,opt);
        case 'viewfilename'
          if ~isa(val,'char')
            error('Value of viewfilename must be a character array.')
          end
          viewfilename = val;
        case 'processview'
          processview = value01(val,opt); 
        case 'cmd1'
          if ~isa(val,'char')
            error('Value of cmd1 must be a character array.')
          end
          cmd1 = val;
        case 'cmd2'
          if ~isa(val,'char')
            error('Value of cmd2 must be a character array.')
          end
          cmd2 = val;
        case 'cmd3'
          if ~isa(val,'char')
            error('Value of cmd3 must be a character array.')
          end
          cmd3 = val;
        case 'cmd4'
          if ~isa(val,'char')
            error('Value of cmd4 must be a character array.')
          end
          cmd4 = val;
        case 'cmd5'
          if ~isa(val,'char')
            error('Value of cmd5 must be a character array.')
          end
          cmd5 = val;
        case 'cmd6'
          if ~isa(val,'char')
            error('Value of cmd6 must be a character array.')
          end
          cmd6 = val;
        case 'cmd7'
          if ~isa(val,'char')
            error('Value of cmd7 must be a character array.')
          end
          cmd7 = val;
        case 'cmd8'
          if ~isa(val,'char')
            error('Value of cmd8 must be a character array.')
          end
          cmd8 = val;
        otherwise
          error(['Option ''' opt ''' unknown'])
      end % switch opt
    end % for i=3:2:nargin 
  end % if nargin > 2
end % try / catch    

if verbose, 
  disp([ 'This is LaPrint, version ' laprintident '.' ]); 
end  

comment   = strrep(strrep(comment,'\','\\'),'%','%%');
caption   = strrep(strrep(caption,'\','\\'),'%','%%');
iscaption = logical(length(caption));

if nzeros < 3
  warning('LaPrint:general',...
          'The value of nzero should be >=3. I will use nzeros=3.')
  nzeros=3;  
end

if processview 
  createview=1;
end

if mathticklabels
  Do='$';
else  
  Do='';
end  

% eps- and tex- filenames
[epsfullnameext,epsbasenameext,epsbasename,epsdirname] = ...
                       getfilenames(filename,'eps',verbose);
[texfullnameext,texbasenameext,texbasename,texdirname] = ...
                       getfilenames(filename,'tex',verbose);
if ~strcmp(texdirname,epsdirname)
   warning('LaPrint:files',['The eps-file and tex-file are '...
          'placed in different directories.']);
end

if createview | processview
  [viewfullnameext,viewbasenameext,viewbasename,viewdirname] = ...
                       getfilenames(viewfilename,'tex',verbose);
  if strcmp(texfullnameext,viewfullnameext)
    viewfilename=[ viewfilename '_'];
    warning('LaPrint:files',['The tex- and view-file coincide. '... 
           'I''ll use '' ' viewfilename ' ''. Hope that''s ok.' ])
  end  
  [viewfullnameext,viewbasenameext,viewbasename,viewdirname]= ...
                       getfilenames(viewfilename,'tex',verbose);
  if ~strcmp(texdirname,viewdirname)
    warning('LaPrint:files',['The eps-file and view-file are '...
	   'placed in different directories.' ])
  end  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% PART 2 of advanced Syntax:
%%%% Create new figure, insert tags, and bookkeep original text
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% show all
shh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

% preparing check for copyobj bug
figno_ori = figno;
number_children_ori = length(get(figno_ori,'children'));

% open new figure (if required) and set properties
if figcopy
  figno = copyobj(figno,0);
  set(figno,'visible','off')
  set(figno,'Numbertitle','off')
  set(figno,'MenuBar','none')
  pause(0.5)
end  

if asonscreen  
  xlimmodeauto       = findobj(figno,'xlimmode','auto');
  xtickmodeauto      = findobj(figno,'xtickmode','auto');
  xticklabelmodeauto = findobj(figno,'xticklabelmode','auto');
  ylimmodeauto       = findobj(figno,'ylimmode','auto');
  ytickmodeauto      = findobj(figno,'ytickmode','auto');
  yticklabelmodeauto = findobj(figno,'yticklabelmode','auto');
  zlimmodeauto       = findobj(figno,'zlimmode','auto');
  ztickmodeauto      = findobj(figno,'ztickmode','auto');
  zticklabelmodeauto = findobj(figno,'zticklabelmode','auto');
  set(xlimmodeauto,'xlimmode','manual')
  set(xtickmodeauto,'xtickmode','manual')
  set(xticklabelmodeauto,'xticklabelmode','manual')
  set(ylimmodeauto,'ylimmode','manual')
  set(ytickmodeauto,'ytickmode','manual')
  set(yticklabelmodeauto,'yticklabelmode','manual')
  set(zlimmodeauto,'ylimmode','manual')
  set(ztickmodeauto,'ytickmode','manual')
  set(zticklabelmodeauto,'yticklabelmode','manual')
end  
set(figno,'paperunits','centimeters');
set(figno,'units','centimeters');
orip = get(figno,'Position');

% determine width and height
if factor <= 0
  factor = width/orip(3);
end 
latexwidth = width;
epswidth   = latexwidth/factor;
epsheight  = epswidth*orip(4)/orip(3);

set(figno,'PaperPosition',[0 0 epswidth epsheight ])
set(figno,'papersize',[epswidth epsheight])
set(figno,'Position',[orip(1)+0.5 orip(2)-0.5 epswidth epsheight ])
set(figno,'Name',[ 'To be printed; size: ' num2str(factor,3) ...
  ' x (' num2str(epswidth,3) 'cm x ' num2str(epsheight,3) 'cm)' ])

% some warnings
if verbose
  if (epswidth<13) | (epsheight<13*0.75)
    warning('LaPrint:size',['The size of the eps-figure is quite '...
       'small. The text objects might not be properly set. '...
       'Reducing ''factor'' might help.'])
  end
  if latexwidth/epswidth<0.5
    warning('LaPrint:size',['The size of the eps-figure is large ' ...
           'compared to the latex figure. '...
           'The text size might be too small. '...
           'Increasing ''factor'' might help.'])
  end  
  if (orip(3)-epswidth)/orip(3) > 0.1
    warning('LaPrint:size',['The size of the eps-figure is much '...
            'smaller than the original '...
            'figure on screen. Matlab might save different ticks '...
            'and ticklabels than in the original figure. '...
            'See option ''asonscreen''.'])
  end
  disp('Strike any key to continue.');
  pause
end  

%
% TEXT OBJECTS: modify new figure 
%

% find all text objects
hxl = get(findobj(figno,'type','axes'),'xlabel');
hyl = get(findobj(figno,'type','axes'),'ylabel');
hzl = get(findobj(figno,'type','axes'),'zlabel');
hti = get(findobj(figno,'type','axes'),'title');
hte = findobj(figno,'type','text');

% array of all text handles
htext = unique([ celltoarray(hxl) celltoarray(hyl) celltoarray(hzl) ...
      celltoarray(hti) celltoarray(hte)]);
nt = length(htext);

% set(celltoarray(hxl),'VerticalAlignment','top');
% get alignments
hora  = get(htext,'HorizontalAlignment');
vera  = get(htext,'VerticalAlignment');
align = cell(nt,1);
for i=1:nt
  align{i} = hora{i}(1);
  switch vera{i}
  case 'top'
    align{i} = [align{i} 't'];
  case 'cap'
%  if ~isempty(get(htext(i),'string'))
%  warning('LaPrint:text',['Using vertical ' ...
%  'alignment ''top'' instead of ''cap''.'])
%  end  
    align{i} = [align{i} 't'];
  case 'middle'
    align{i} = [align{i} 'c'];
  case 'baseline'
    align{i} = [align{i} 'B'];
  case 'bottom'
    align{i} = [align{i} 'b'];
  otherwise
    warning('LaPrint:text',['Vertical alignment ' vera{i} ...
            ' unknown. Using ''c''.'])
    align{i} = [align{i} 'c'];
  end
end  

% generate new strings and store old ones
oldstr   = get(htext,'string');
newstr   = cell(nt,1);
basestr  = ['s' char(48*ones(1,nzeros-1))];
extrastr = 0;
for i=1:nt
  osi = oldstr{i};
  oldstr{i} = ['\setlength{\tabcolsep}{0pt}\begin{tabular}{' ...
          align{i}(1) '}'];
  isnonempty_osi = 0;
  if strcmp(get(get(htext(i),'parent'),'tag'),'legend')
    newstr1 = [];  
    if isa(osi,'cell')
      % Legend/cell : Don't use tabular, employ extra strings 
      nlines = length(osi);
      if nlines > 1
        newstr{nt+extrastr+nlines-1} = [];
        oldstr{nt+extrastr+nlines-1} = [];
        htext((nt+extrastr+1):(nt+extrastr+nlines-1))=htext(i);
        for line=1:nlines-1  
          oldstr{nt+extrastr+line} = ...
              strrep(strrep(osi{line},'\','\\'),'%','%%'); 
          newstr{nt+extrastr+line} = ...
              overwritetail(basestr,nt+extrastr+line);
          newstr1 = [newstr1; overwritetail(basestr,nt+extrastr+line)]; 
        end    
        extrastr = extrastr+nlines-1;  
      end    
      if nlines > 0
        oldstr{i} = strrep(strrep(osi{nlines},'\','\\'),'%','%%'); 
        newstr{i} = overwritetail(basestr,i);
        newstr1   = [newstr1; overwritetail(basestr,i)]; 
      end  
      % replace strings in figure
      set(htext(i),'string',cellstr(newstr1));
    else
      % Legend/matrix : Don't use tabular, employ extra strings 
      nlines=size(osi,1);
      if nlines > 1
        newstr{nt+extrastr+nlines-1} = [];
        oldstr{nt+extrastr+nlines-1} = [];
        htext((nt+extrastr+1):(nt+extrastr+nlines-1))=htext(i);
        for line=1:nlines-1  
          oldstr{nt+extrastr+line} = ...
              strrep(strrep(osi(line,:),'\','\\'),'%','%%'); 
          newstr{nt+extrastr+line} = ...
              overwritetail(basestr,nt+extrastr+line);
          newstr1 = [newstr1; overwritetail(basestr,nt+extrastr+line)]; 
        end    
        extrastr = extrastr+nlines-1;  
      end    
      if nlines > 0
        oldstr{i} = strrep(strrep(osi(nlines,:),'\','\\'),'%','%%'); 
        newstr{i} = overwritetail(basestr,i);
        newstr1   = [newstr1; overwritetail(basestr,i)]; 
      end  
      % replace strings in figure
      set(htext(i),'string',newstr1);
    end
  else
    % text, not a legend  
    if isa(osi,'cell')
      nlines = length(osi);
      if nlines > 1
        for line=1:nlines-1  
          oldstr{i}=[oldstr{i} osi{line} '\\'];
          isnonempty_osi = isnonempty_osi+length(osi{line});  
        end    
        if align{i}(2) == 'B'
          warning('LaPrint:text',['Vertical Alignment ''baseline'' '...
                  'in text with multiple rows might not match.'])
          align{i}(2) = 't';
        end  
      end    
      if nlines > 0
        oldstr{i} = [oldstr{i} osi{nlines} '\end{tabular}'];
        isnonempty_osi = isnonempty_osi+length(osi{nlines});
      end  
      oldstr{i} = strrep(strrep(oldstr{i},'\','\\'),'%','%%');  
      if isnonempty_osi
        newstr{i} = overwritetail(basestr,i);
      else  
        newstr{i} = '';    
      end
      % replace strings in figure
      set(htext(i),'string',newstr{i}); 
    else
      nlines=size(osi,1);
      if nlines > 1
        for line=1:nlines-1  
          oldstr{i} = [oldstr{i} osi(line,:) '\\'];
          isnonempty_osi = isnonempty_osi+length(osi(line,:));  
        end    
        if align{i}(2) == 'B'
          warning('LaPrint:text',['Vertical Alignment ''baseline'' '...
                  'in text with multiple rows might not match.'])
          align{i}(2) = 't';
        end  
      end
      if nlines > 0
        oldstr{i} = [oldstr{i} osi(nlines,:) '\end{tabular}'];
        isnonempty_osi = isnonempty_osi+length(osi(nlines,:));
      end  
      oldstr{i} = strrep(strrep(oldstr{i},'\','\\'),'%','%%');  
   
      if isnonempty_osi
        newstr{i} = overwritetail(basestr,i);
      else  
        newstr{i} = '';    
      end
      % replace string in figure
      set(htext(i),'string',newstr{i});
    end % isa cell  
  end % isa legend  
end % for

ntp = nt+extrastr;

% Alignment of Legends
if extrastr > 0
  align{ntp} = [];
  [align{nt+1:ntp}] = deal('lc');
end

% get font properties and create commands
if ntp > 0
  [fontsizecmd{1:ntp}]   = deal('');
  [fontanglecmd{1:ntp}]  = deal('');
  [fontweightcmd{1:ntp}] = deal('');
  [colorcmd{1:ntp}]      = deal('');
  [colorclose{1:ntp}]    = deal('');
end
selectfontcmd = '';

if keepfontprops

  % fontsize
  set(htext,'fontunits','points');
  fontsize = get(htext,'fontsize');
  for i=1:ntp
    fontsizecmd{i} = [ '\\fontsize{' num2str(fontsize{i}) '}{' ...
	  num2str(fontsize{i}*1.5) '}'  ];
  end
    
  % fontweight
  fontweight = get(htext,'fontweight');
  for i=1:ntp
    switch fontweight{i}
    case 'light'
      fontweightcmd{i} = [ '\\fontseries{l}\\mathversion{normal}' ];
    case 'normal'
      fontweightcmd{i} = [ '\\fontseries{m}\\mathversion{normal}' ];
    case 'demi'
      fontweightcmd{i} = [ '\\fontseries{sb}\\mathversion{bold}' ];
    case 'bold'
      fontweightcmd{i} = [ '\\fontseries{bx}\\mathversion{bold}' ];
    otherwise
      warning('LaPrint:text',['Unknown fontweight: ' fontweight{i} ])
      fontweightcmd{i} = [ '\\fontseries{m}\\mathversion{normal}' ];
    end
  end  

  % fontangle
  fontangle = get(htext,'fontangle');
  for i=1:ntp
    switch fontangle{i}
    case 'normal'
      fontanglecmd{i} = [ '\\fontshape{n}' ];
    case 'italic'
      fontanglecmd{i} = [ '\\fontshape{it}' ];
    case 'oblique'
      fontanglecmd{i} = [ '\\fontshape{it}' ];
    otherwise
      warning('LaPrint:text',['unknown fontangle: ' fontangle{i} ])
      fontanglecmd{i} = [ '\\fontshape{n}' ];
    end
  end  
  selectfontcmd = '\\selectfont ';
   
end

if color & ntp>0
  col   = get(htext,'color');
  bgcol = get(htext,'BackgroundColor');
  ecol  = get(htext,'EdgeColor');
  for i=1:ntp
    col0           = get(get(htext(i),'parent'),'color'); 
    [coli,isc]     = char2rgb(col{i},[0 0 0]);
    [bgcoli,isbgc] = char2rgb(bgcol{i},col0);
    [ecoli,isec]   = char2rgb(ecol{i},col0);
    if isbgc | isec
      set(htext(i),'BackgroundColor','none')
      set(htext(i),'EdgeColor','none')
      colorcmd{i} = ['\\setlength{\\fboxsep}{2pt}\\fcolorbox[rgb]{' ...
        num2str(ecoli(1)) ',' num2str(ecoli(2)) ',' ...
        num2str(ecoli(3)) '}{' ...
        num2str(bgcoli(1)) ',' num2str(bgcoli(2)) ',' ...
        num2str(bgcoli(3)) '}{\\color[rgb]{' ...
        num2str(coli(1)) ',' num2str(coli(2)) ',' num2str(coli(3)) '}' ];  
      colorclose{i} = '}';   
    else  
      colorcmd{i} = ['\\color[rgb]{' ...
        num2str(coli(1)) ',' num2str(coli(2)) ',' num2str(coli(3)) '}' ];
    end  
  end  
end

%
% LABELS: modify new figure
%

if ~keepticklabels

  % all axes
  hax = celltoarray(findobj(figno,'type','axes'));
  na  = length(hax);

%  % try to figure out if we have 3D axes an warn
%  issuewarning = 0;
%  for i=1:na
%  issuewarning = max(issuewarning,is3d(hax(i)));
%  end
%  if issuewarning
%  warning('LaPrint:label',['This seems to be a 3D plot. '...
%  'The LaTeX labels are possibly incorrect. '...
%  'The option  ''keepticklabels'' might help. '...
%  'Setting ''figcopy'' to ''off'' might be wise, too.'])
%  end

  % try to figure out if we linear scale with extra factor 
  % and determine powers of 10
  powers = NaN*zeros(na,3);  % matrix with powers of 10 
  for i=1:na                    % all axes
    allxyz = { 'x', 'y', 'z' };
    for ixyz=1:3                % x,y,z
      xyz = allxyz{ixyz};
      ticklabelmode = get(hax(i),[ xyz 'ticklabelmode']);
      if strcmp(ticklabelmode,'auto')
        tick      = get(hax(i),[ xyz 'tick']);
        ticklabel = get(hax(i),[ xyz 'ticklabel']);	      
	    nticklabels    = size(ticklabel,1);
	    nticks    = length(tick);
	    if nticks==0,
          powers(i,ixyz)=0;
          nticklabels=0;
	    end  
	    if nticklabels==0,
          powers(i,ixyz)=0;
  	    end  
        for k=1:nticklabels    % all ticks
	      label = str2num(ticklabel(k,:));
	      if length(label)==0, 
	        powers(i,ixyz) = 0;
	        break; 
	      end  
	      if ( label==0 ) & ( abs(tick(k))>1e-10 )
	        powers(i,ixyz) = 0;
	        break; 
          end	      
	      if label~=0    
            expon  = log10(tick(k)/label);
	        rexpon = round(expon);
	        if abs(rexpon-expon)>1e-10
              powers(i,ixyz) = 0;
	          break; 
            end	
            if isnan(powers(i,ixyz))
	          powers(i,ixyz) = rexpon;
	        else 	
	          if powers(i,ixyz)~=rexpon
        	    powers(i,ixyz) = 0;
	            break; 
              end		
	        end 
          end  	    
	    end % k	    
      else % if 'auto'
        powers(i,ixyz) = 0;
      end % if 'auto'
    end % ixyz
  end % i
  
  % place text to be replaced by powers on y-axis
  for i=1:na             
    allxyz = { 'x', 'y', 'z' };
    ixyz=2;                % x,y,z
    xyz = allxyz{ixyz};
    leftright=get(hax(i),'yaxislocation');
    if powers(i,ixyz) & ~is3d(hax(i)) & isequal(leftright,'left')
        powertext = ['ypower' int2str(i)];
        xlimit    = get(hax(i),'xlim');
        ylimit    = get(hax(i),'ylim');
        htext     = text(xlimit(1),ylimit(2)+...
                  0.01*(ylimit(2)-ylimit(1)),...
                  powertext);
        set(htext,'VerticalAlignment','Baseline');
    end
  end % i

  % replace all ticklabels and bookkeep
  nxlabel = zeros(1,na);
  nylabel = zeros(1,na);
  nzlabel = zeros(1,na);
  allxyz={ 'x', 'y', 'z' }; 
  for ixyz=1:3
    xyz = allxyz{ixyz};
    k=1;
    if strcmp(xyz,'y') 
      basestr = [ 'v' char(48*ones(1,nzeros-1))];
    else
      basestr = [ xyz char(48*ones(1,nzeros-1))];
    end  
    oldtl  = cell(na,1);
    newtl  = cell(na,1);
    nlabel = zeros(1,na);
    for i=1:na
      % set(hax(i),[ xyz 'tickmode' ],'manual')
      % set(hax(i),[ xyz 'ticklabelmode' ],'manual')
      oldtl{i}  = chartocell(get(hax(i),[ xyz 'ticklabel' ]));
      nlabel(i) = length(oldtl{i});
      newtl{i}  = cell(1,nlabel(i));
      for j=1:nlabel(i)
        newtl{i}{j} = overwritetail(basestr,k);
        k = k+1;
        oldtl{i}{j} = deblank(strrep(strrep(oldtl{i}{j},'\','\\'),...
                             '%','%%'));
      end
      set(hax(i),[ xyz 'ticklabel' ],newtl{i});
    end  
    eval([ 'old' xyz 'tl=oldtl;' ]);
    eval([ 'new' xyz 'tl=newtl;' ]);
    eval([ 'n' xyz 'label=nlabel;' ]);
  end

  % determine latex commands for font properties
  
  if keepfontprops

    % ticklabel font size
    afsize = zeros(na,1);
    for i=1:na
      afsize(i) = get(hax(i),'fontsize');
    end          
    if (any(afsize ~= afsize(1) ))
      warning('LaPrint:text',['Different font sizes for axes not '...
              'supported. All axes will have font size ' ...
	           num2str(afsize(1)) '.' ] )
    end      
    afsizecmd = [ '\\fontsize{' num2str(afsize(1)) '}{' ...
	  num2str(afsize(1)*1.5) '}'  ];

    % ticklabel font weight
    afweight = cell(na,1);
    for i=1:na
      afweight{i} = get(hax(i),'fontweight');
    end
    switch afweight{1}
    case 'light'
      afweightcmd = [ '\\fontseries{l}\\mathversion{normal}' ];
    case 'normal'
      afweightcmd = [ '\\fontseries{m}\\mathversion{normal}' ];
    case 'demi'
      afweightcmd = [ '\\fontseries{sb}\\mathversion{bold}' ];
    case 'bold'
      afweightcmd = [ '\\fontseries{bx}\\mathversion{bold}' ];
    otherwise
      warning('LaPrint:text',['unknown fontweight: ' afweight{1} ])
      afweightcmd = [ '\\fontseries{m}\\mathversion{normal}' ];
    end
    for i=1:na
      if ~strcmp(afweight{i},afweight{1})
        warning('LaPrint:text',['Different font weights for axes '...
                'are not supported. All axes will have font weight ' ...
                afweightcmd '.'])
      end      
    end      

    % ticklabel font angle
    afangle = cell(na,1);
    for i=1:na
      afangle{i} = get(hax(i),'fontangle');
    end
    switch afangle{1}
    case 'normal'
      afanglecmd = [ '\\fontshape{n}' ];
    case 'italic'
      afanglecmd = [ '\\fontshape{it}' ];
    case 'oblique'
      afanglecmd = [ '\\fontshape{it}' ];
    otherwise
      warning('LaPrint:text',['unknown fontangle: ' afangle{1} ])
      afanglecmd=[ '\\fontshape{n}' ];
    end
    for i=1:na
      if ~strcmp(afangle{i},afangle{1})
        warning('LaPrint:text',['Different font angles for axes not '...
                'supported. All axes will have font angle ' ...
                afanglecmd '.'] )
      end      
    end      
  
  end

  % ticklabel color
  acolcmd='';
  if color
    acol=[];
    allxyz={ 'x', 'y', 'z' }; 
    acolwarn = 0;
    for i=1:na
      for ixyz=1:3
        xyzcolor = [allxyz{ixyz} 'color'];
        if  ~isempty(get(hax(i),[allxyz{ixyz} 'ticklabel']))
          if isempty(acol)
            acol = char2rgb(get(hax(i),xyzcolor));  
          else
            if any(char2rgb(get(hax(i),xyzcolor))~=acol)
              acolwarn = 1;
            end 
          end
        end   
      end 
    end
    if acolwarn
      warning('LaPrint:label',['Different colors for axes not ' ...
            'supported. All ticklabels will have color [ ' ...
             num2str(acol) ' ].' ] )
    end
    if ~isempty(acol)
      if any(acol~=[0 0 0])
        acolcmd = [ '\\color[rgb]{' num2str(acol(1)) ',' ...
              num2str(acol(2)) ',' num2str(acol(3)) '}' ];
      end	
    end 
  end

  % ticklabel alignment
    xyzalign = char([116*ones(na,1) 114*ones(na,1) 114*ones(na,1)]); 
    for i=1:na
      switch get(hax(i),'XAxisLocation')
      case 'top'
        xyzalign(i,1)='B';
      end
      switch get(hax(i),'YAxisLocation')
      case 'right'
        xyzalign(i,2)='l';
      end
    end

end

%
% extra picture environment
%

if extrapicture
  unitlength = zeros(na,1);
  ybound     = zeros(na,1);
  for i=na:-1:1   % reverse order, to keep axes in original order
    if ~is3d(hax(i))
      xlim = get(hax(i),'xlim');
      ylim = get(hax(i),'ylim');
      axes(hax(i));
      hori = text(ylim(1),ylim(1),[ 'origin' int2str(i) ]);
      set(hori,'VerticalAlignment','bottom');
      set(hori,'Fontsize',2);
      set(hax(i),'Units','normalized')
      pos = get(hax(i),'Position');
      unitlength(i) = pos(3)*epswidth;
      ybound(i) = (pos(4)*epsheight)/(pos(3)*epswidth);
    else
      warning('LaPrint:extrapic',['Option ''extrapicture'' for 3D ' ...
                  'axes not supported.'])
    end
  end 
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% PART 3 of advanced Syntax:
%%%% save eps and tex files
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prevent matlab print command to modify lims and ticks 
% (empty, if asonscreen=1)
if ~keepticklabels
  xlimmodeauto       = findobj(figno,'xlimmode','auto');
  xtickmodeauto      = findobj(figno,'xtickmode','auto');
  xticklabelmodeauto = findobj(figno,'xticklabelmode','auto');
  ylimmodeauto       = findobj(figno,'ylimmode','auto');
  ytickmodeauto      = findobj(figno,'ytickmode','auto');
  yticklabelmodeauto = findobj(figno,'yticklabelmode','auto');
  zlimmodeauto       = findobj(figno,'zlimmode','auto');
  ztickmodeauto      = findobj(figno,'ztickmode','auto');
  zticklabelmodeauto = findobj(figno,'zticklabelmode','auto');
  set(xlimmodeauto,'xlimmode','manual')
  set(xtickmodeauto,'xtickmode','manual')
  set(xticklabelmodeauto,'xticklabelmode','manual')
  set(ylimmodeauto,'ylimmode','manual')
  set(ytickmodeauto,'ytickmode','manual')
  set(yticklabelmodeauto,'yticklabelmode','manual')
  set(zlimmodeauto,'ylimmode','manual')
  set(ztickmodeauto,'ytickmode','manual')
  set(zticklabelmodeauto,'yticklabelmode','manual')
end

% create eps file
cmd = strrep(printcmd,'<filename.eps>',epsfullnameext);
cmd = strrep(cmd,'<filename>',filename);
cmd = strrep(cmd,'<figurenumber>',int2str(figno));
  
if verbose
  disp([ 'executing: '' ' cmd ' ''' ]);
end
eval(cmd);

%
% create latex file
%
if verbose
  disp([ 'writing to: '' ' texfullnameext ' ''' ])
end
fid = fopen(texfullnameext,'w');

% head
if head
  fprintf(fid,[ '%% This file is generated by the MATLAB m-file' ...
       ' laprint.m. It can be included\n']);
  fprintf(fid,[ '%% into LaTeX documents using the packages ']);
  fprintf(fid,package);
  if color
      fprintf(fid,', color');
  end    
  fprintf(fid,[ ' and psfrag.\n' ]);
  fprintf(fid,  ['%% It is accompanied by a postscript file. ',... 
     'A sample LaTeX file is:\n']);
  fprintf(fid, '%%  \\documentclass{article}\\usepackage{');
  fprintf(fid,package);
  if color
     fprintf(fid,',color');
  end    
  fprintf(fid, ',psfrag}\n');
  fprintf(fid,[ '%%  \\begin{document}\\input{' ...
	texbasename '}\\end{document}\n' ]);
    fprintf(fid, [ '%% See http://www.mathworks.de/matlabcentral'...
      '/fileexchange/loadFile.do?objectId=4638\n']);
    fprintf(fid, [ '%% for recent versions of laprint.m.\n' ]);
  fprintf(fid,  '%%\n');
  fprintf(fid,[ '%% created by:           ' 'LaPrint version ' ...
	laprintident '\n' ]);
  fprintf(fid,[ '%% created on:           ' datestr(now) '\n' ]);
  fprintf(fid,[ '%% eps bounding box:     ' num2str(epswidth) ...
      ' cm x ' num2str(epsheight) ' cm\n' ]);
  fprintf(fid,[ '%% comment:              ' comment '\n' ]);
  fprintf(fid,'%%\n');
else 
  fprintf(fid,[ '%% generated by laprint.m\n' ]);
  fprintf(fid,'%%\n');
end

% go on
fprintf(fid,'\\begin{psfrags}%%\n');
%fprintf(fid,'\\fontsize{10}{12}\\selectfont%%\n');
fprintf(fid,'\\psfragscanon%%\n');

% text strings

numbertext=0;
for i=1:nt
  numbertext = numbertext+length(newstr{i});
end
if numbertext>0,
  fprintf(fid,'%%\n');
  fprintf(fid,'%% text strings:\n');
  for i=1:ntp
    if length(newstr{i})
      alig = strrep(align{i},'c','');
      fprintf(fid,[ '\\psfrag{' newstr{i} '}[' alig '][' alig ']{' ...
        fontsizecmd{i} fontweightcmd{i} fontanglecmd{i}  ...
        selectfontcmd colorcmd{i} oldstr{i} colorclose{i} '}%%\n' ]);
    end
  end
end

% labels

if ~keepticklabels
  if ~isempty(acolcmd)
     fprintf(fid,'%%\n');
     fprintf(fid,'%% axes ticklabel color:\n');
     fprintf(fid,[ acolcmd '%%\n' ]);
  end    
  if keepfontprops
    fprintf(fid,'%%\n');
    fprintf(fid,'%% axes font properties:\n');
    fprintf(fid,[ afsizecmd afweightcmd '%%\n' ]);
    fprintf(fid,[ afanglecmd '\\selectfont%%\n' ]);
  end  
  nxlabel = zeros(1,na);
  nylabel = zeros(1,na);
  nzlabel = zeros(1,na);
  for i=1:na
    nxlabel(i) = length(newxtl{i});
    nylabel(i) = length(newytl{i});
    nzlabel(i) = length(newztl{i});
  end    
      
  allxyz = { 'x', 'y', 'z' };
  for ixyz=1:3
    xyz = allxyz{ixyz};
    eval([ 'oldtl=old' xyz 'tl;' ]);
    eval([ 'newtl=new' xyz 'tl;' ]);
    eval([ 'nlabel=n' xyz 'label;' ]);
    if sum(nlabel) > 0
      fprintf(fid,'%%\n');
      fprintf(fid,[ '%% ' xyz 'ticklabels:\n']);
      for i=1:na
        poss = ['[' xyzalign(i,ixyz) '][' xyzalign(i,ixyz) ']']; 
        if nlabel(i)
          if strcmp(get(hax(i),[ xyz 'scale']),'linear')
	        % lin scale
            rexpon = powers(i,ixyz);
            if ~rexpon 
              % no powers
              for j=1:nlabel(i)
                fprintf(fid,[ '\\psfrag{' newtl{i}{j} '}' poss '{' ...
		                    Do oldtl{i}{j} Do '}%%\n' ]);
              end 
            else
              % powers
              if ixyz==2 
                leftright=get(hax(i),'yaxislocation');
                if ~is3d(hax(i)) & isequal(leftright,'left')
                  for j=1:nlabel(i)
                    fprintf(fid,[ '\\psfrag{' newtl{i}{j} '}' poss '{' ...
	 	                    Do oldtl{i}{j} Do '}%%\n' ]);
                  end 
                  fprintf(fid,[ '\\psfrag{ypower' int2str(i) ...
                     '}[Bl][Bl]{$\\times 10^{' ...
 		             int2str(rexpon) '}$}%%\n' ]);
                else
                  for j=1:nlabel(i)-1
                    fprintf(fid,[ '\\psfrag{' newtl{i}{j} '}' poss '{' ...
		                      Do oldtl{i}{j} Do '}%%\n' ]);
                  end 
                  if ~is3d(hax(i))
	                fprintf(fid,[ '\\psfrag{' newtl{i}{nlabel(i)} ...
                     '}' poss '{' ... 
                     Do oldtl{i}{nlabel(i)} Do '$\\times 10^{'...
		             int2str(rexpon) '}$}%%\n' ]);
                  else
 	                fprintf(fid,[ '\\psfrag{' newtl{i}{nlabel(i)} ...
                     '}' poss '{\\shortstack{' ... 
                     Do oldtl{i}{nlabel(i)} Do '\\\\$\\times 10^{'...
		             int2str(rexpon) '}\\ $}}%%\n' ]);

                  end 
                end  
              elseif ixyz==1
                for j=1:nlabel(i)-1
                  fprintf(fid,[ '\\psfrag{' newtl{i}{j} '}' poss '{' ...
		                    Do oldtl{i}{j} Do '}%%\n' ]);
                end 
                leftright=get(hax(i),'xaxislocation');
                if isequal(leftright,'bottom')
	              fprintf(fid,[ '\\psfrag{' newtl{i}{nlabel(i)} ...
                     '}' poss '{\\shortstack{' ... 
                     Do oldtl{i}{nlabel(i)} Do '\\\\$\\times 10^{'...
		             int2str(rexpon) '}\\ $}}%%\n' ]);
	            else
                  fprintf(fid,[ '\\psfrag{' newtl{i}{nlabel(i)} ...
                     '}' poss '{\\shortstack{$\\times 10^{' ...
                     int2str(rexpon) '}\\ $\\\\' ...
                     Do oldtl{i}{nlabel(i)} Do '}}%%\n' ]);
                end
              else
                for j=1:nlabel(i)-1
                  fprintf(fid,[ '\\psfrag{' newtl{i}{j} '}' poss '{' ...
		                    Do oldtl{i}{j} Do '}%%\n' ]);
                end 
	            fprintf(fid,[ '\\psfrag{' newtl{i}{nlabel(i)} ...
		           '}' poss '{' Do oldtl{i}{nlabel(i)} Do ...
                   '\\setlength{\\unitlength}{1ex}' ...
		           '\\begin{picture}(0,0)\\put(0.5,1.5){$\\times 10^{' ...
		           int2str(rexpon) '}$}\\end{picture}}%%\n' ]);
              end 
            end % rexpon 
          else
            % log scale
            for j=1:nlabel(i)
              fprintf(fid,[ '\\psfrag{' newtl{i}{j} '}' poss '{$10^{' ...
                oldtl{i}{j} '}$}%%\n' ]);
            end % for (log)
          end % if linear
        end  % if nlabel(i) 
      end
    end
  end
end  

% extra picture
if extrapicture
  fprintf(fid,'%%\n');
  fprintf(fid,'%% extra picture(s):\n');
  for i=1:na
    fprintf(fid,[ '\\psfrag{origin' int2str(i) '}[lb][lb]{' ...
                  '\\setlength{\\unitlength}{' ...
		  num2str(unitlength(i),'%5.5f') 'cm}%%\n' ]);
    fprintf(fid,[ '\\begin{picture}(1,' ...
		  num2str(ybound(i),'%5.5f') ')%%\n' ]);
    %fprintf(fid,'\\put(0,0){}%% lower left corner\n');
    %fprintf(fid,[ '\\put(1,' num2str(ybound(i),'%5.5f') ...
%  '){}%% upper right corner\n' ]);
    fprintf(fid,'\\end{picture}%%\n');
    fprintf(fid,'}%%\n');
  end
end  

% figure
fprintf(fid,'%%\n');
fprintf(fid,'%% Figure:\n');
if iscaption
  fprintf(fid,[ '\\parbox{' num2str(latexwidth) 'cm}{\\centering%%\n' ]);
end  
if ~scalefonts
  switch package
  case 'epsfig'   
     fprintf(fid,[ '\\epsfig{file=' epsbasenameext ',width=' ...
	 num2str(latexwidth) 'cm}%%\n' ]);
  case 'graphicx'   
     fprintf(fid,[ '\\includegraphics[width=' num2str(latexwidth) ...
             'cm]{' epsbasenameext '}%%\n' ]);
  otherwise  
    warning('LaPrint:general',['Package ''' package ''' not known. '...
            'I hope you know what you are doing...'])    
  end
else
  switch package
  case 'epsfig'  
     fprintf(fid,[ '\\resizebox{' num2str(latexwidth) 'cm}{!}' ...
      '{\\epsfig{file=' epsbasenameext '}}%%\n' ]);
  case 'graphicx' 
     fprintf(fid,[ '\\resizebox{' num2str(latexwidth) 'cm}{!}' ...
      '{\\includegraphics{' epsbasenameext '}}%%\n' ]);
  otherwise
    warning('LaPrint:general',['Package ''' package ''' not known. '...
            'I hope you know what you are doing...'])    
  end
end
if iscaption
  fprintf(fid,[ '\\caption{' caption '}%%\n' ]);
  fprintf(fid,[ '\\label{fig:' texbasename '}%%\n' ]);
  fprintf(fid,[ '}%%\n' ]);
end  
fprintf(fid,'\\end{psfrags}%%\n');
fprintf(fid,'%%\n');
fprintf(fid,[ '%% End ' texbasenameext '\n' ]);
fclose(fid);

set(figno,'Name','Printed by LaPrint')
if figcopy
  if verbose
    disp('Strike any key to continue.');
    pause
  end
  hlegend = findobj(figno,'Tag','legend');
  set(hlegend,'DeleteFcn','')
  close(figno)
end

% check for copyobj-bug --> should be ok now!
number_children_new = length(get(figno_ori,'children'));
if number_children_new < number_children_ori
   if figcopy 
      warning(['LaPrint:general','Objects in the figure have been '...
              'deleted! This is due to a bug in matlabs '...
              '''copyopj''. You might want to try to set '...
              '''figcopy'' to ''off''.']) 
   else    
      warning('LaPrint:general',['Objects in the figure have been '...
              'deleted!'])
   end
 end
    
%
% create view file
%

if createview | processview
  if verbose
    disp([ 'writing to: '' ' viewfullnameext ' ''' ])
  end
  fid = fopen(viewfullnameext,'w');

  if head
    fprintf(fid,[ '%% This file is generated by laprint.m.\n' ]);
    fprintf(fid,[ '%% It calls ' texbasenameext ...
		  ', which in turn  calls ' epsbasenameext '.\n' ]);
    fprintf(fid,[ '%% Process this file using, e.g.,\n' ]);
    fprintf(fid,[ '%%  latex ' viewbasenameext '\n' ]);
    fprintf(fid,[ '%%  dvips -o' viewbasename '.ps ' viewbasename ...
            '.dvi\n']);
    fprintf(fid,[ '%%  ghostview ' viewbasename '.ps&\n' ]);
  else 
    fprintf(fid,[ '%% generated by laprint.m\n' ]);
  end

  fprintf(fid,[ '\\documentclass{article}\n' ]);
  fprintf(fid,[ '\\usepackage{' ]);
  fprintf(fid,package);
  if color
      fprintf(fid,',color');
  end    
  fprintf(fid,[ ',psfrag,a4}\n' ]);
  fprintf(fid,[ '\\usepackage[latin1]{inputenc}\n' ]);
  if ~strcmp(epsdirname,viewdirname)
    fprintf(fid,[ '\\graphicspath{{' epsdirname '}}\n' ]);
  end  
  fprintf(fid,[ '\\begin{document}\n' ]);
  fprintf(fid,[ '\\pagestyle{empty}\n' ]);
  if strcmp(texdirname,viewdirname) 
    fprintf(fid,[ '    \\input{' texbasenameext '}\n' ]);
  else
    fprintf(fid,[ '    \\input{' texdirname texbasenameext '}\n' ]);
  end
  fprintf(fid,[ '\\end{document}\n' ]);
  fclose(fid);
end

% process view file
    
if processview
    conti=1;
    
    for i=1:8
      eval(['cmdi=cmd' int2str(i) ';'])
      if ~isempty(cmdi) & conti
        cmd = strrep(cmdi,'<viewfile>',viewbasename);
        cmd = strrep(cmd,'<filename>',filename);
        disp([ 'executing: '' ' cmd ' ''' ]);
        [stat,resu]=system(cmd);
        if stat %| isempty(strfind(resu,'Output written on'))
          disp(resu)
          conti=0;
        end
      end 
    end

    if ~conti
       disp('An error occured in the latex/friends sequence.')
    end

end

set(0,'ShowHiddenHandles',shh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% functions used
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fullnameext,basenameext,basename,dirname] = getfilenames(...
    filename,extension,verbose);
% appends an extension to a filename (as '/home/tom/tt') and determines  
% fullnameext: filename with extension and dirname, as '/home/tom/tt.tex'
% basenameext: filename with extension without dirname, as 'tt.tex'
% basename   : filename without extension without dirname, as 'tt'
% dirname    : dirname without filename, as '/home/tom/'
% In verbose mode, it asks if to overwrite or to modify.
%
[dirname, basename] = splitfilename(filename);
fullnameext = [ dirname basename '.' extension ];
basenameext = [ basename '.' extension ];
if verbose
  quest = (exist(fullnameext)==2);
  while quest
    yn = input([ strrep(strrep(fullnameext,'\','\\'),'%','%%') ...
            ' exists. Overwrite? (y/n) '],'s');
    if strcmp(yn,'y') 
      quest = 0;
    else
      filename = input( ...
	             [ 'Please enter new filename (without extension .' ...
	             extension '): ' ],'s');
      [dirname, basename] = splitfilename(filename);
      fullnameext = [ dirname basename '.' extension ];
      basenameext = [ basename '.' extension ];
      quest = (exist(fullnameext)==2);
    end
  end
end
if ( exist(dirname)~=7 & ~strcmp(dirname,[ '.' filesep ]) ...
      & ~strcmp(dirname,filesep) )
  error([ 'Directory ' dirname ' does not exist.' ] )
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dirname,basename] = splitfilename(filename);
% splits filename into dir and base
slashpos  = findstr(filename,filesep);
nslash    = length(slashpos);
nfilename = length(filename);
if nslash
  dirname  = filename(1:slashpos(nslash));
  basename = filename(slashpos(nslash)+1:nfilename);
else
  dirname = pwd;
  nn=length(dirname);
  if ~strcmp(dirname(nn),filesep)
    dirname = [ dirname filesep ];
  end   
  basename = filename;
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yesno = is3d(haxes);
% tries to figure out if axes is 3D
yesno = 0;
CameraPosition = get(haxes,'CameraPosition');
CameraTarget = get(haxes,'CameraTarget');
CameraUpVector = get(haxes,'CameraUpVector');
if CameraPosition(1)~=CameraTarget(1)
  yesno = 1;
end  
if CameraPosition(2)~=CameraTarget(2)
  yesno = 1;
end  
if any(CameraUpVector~=[0 1 0])
  yesno = 1;
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function b = celltoarray(a);
% converts a cell of doubles to an array
if iscell(a),
  b = [];
  for i=1:length(a),
    b = [b a{i}]; 
  end  
else, 
  b = a(:)';
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function b = chartocell(a)
% converts a character array into a cell array of characters

% convert to cell 
if isa(a,'char')
  n = size(a,1);
  b = cell(1,n);
  for j=1:n
    b{j}=a(j,:); 
  end  
else
  b = a;
end  
% convert to char
n=length(b);
for j=1:n
  if isa(b{j},'double')
    b{j} = num2str(b{j});
  end  
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function b = overwritetail(a,k)
% overwrites tail of a by k
% a,b: strings
% k: integer
ks = int2str(k);
b = [ a(1:(length(a)-length(ks))) ks ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rgb,isc] = char2rgb(c,c0)
% convert color definitions from character to rgb-vector

isc = 1;
if ~ischar(c)
  rgb = c; 
else  
  switch c
  case {'y','yellow'}
    rgb = [1 1 0];
  case {'m','magenta'}
    rgb = [1 0 1];
  case {'c','cyan'}
    rgb = [0 1 1];
  case {'r','red'}
    rgb = [1 0 0];
  case {'g','green'}
    rgb = [0 1 0];
  case {'b','blue'}
    rgb = [0 0 1];
  case {'w','white'}
    rgb = [1 1 1];
  case {'k','black'}
    rgb = [0 0 0];
  case 'none' 
    if nargin==2
      rgb = char2rgb(c0);
    else
      rgb = [1 1 1];    
    end    
    isc = 0;
  otherwise
    warning('LaPrint:general',['Unknown Color: ''' c ...
            '''. Taking black.'])
    rgb = [0 0 0];
  end    
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = value01(val,opt)
% convert off/on to 0/1

if nargin==2
   txt = ['Value of ' opt ' must be ''on'' or ''off'''];
else
   txt = ['Value must be ''on'' or ''off'''];
end

if  ~isa(val,'char')  
  error(txt)
end
val = lower(strrep(val,' ',''));
switch val
  case 'on'
    v = 1;
  case 'off'
    v = 0;
  otherwise
    error(txt)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = valueyn(val)
% convert 0/1 to off/on 

if  ~isa(val,'double')  
  error([ 'Value must be ''0'' or ''1'''])
end
switch val
  case 0
    v = 'off';
  case 1
    v = 'on';
  otherwise
    error([ 'Value must be ''0'' or ''1'''])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sethf(hf,LAPRINTHAN,LAPRINTOPT)
% store in UserData of gui 

set(hf,'UserData',{LAPRINTHAN,LAPRINTOPT})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [LAPRINTHAN,LAPRINTOPT]=gethf(hf)
% load from UserData of gui 

d=get(hf,'UserData');
LAPRINTHAN=d{1};
LAPRINTOPT=d{2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function opt = prefsettings
    if ispref('LaPrint','LAPRINTOPT')  
      opt = getpref('LaPrint','LAPRINTOPT');
    else
      opt = [];  
    end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function opt=factorysettings

% try to find LaTeX and friends 
if ispc
  try 
    latexpath = winqueryreg('HKEY_LOCAL_MACHINE',...
	  'SOFTWARE\MiK\MiKTeX\CurrentVersion\MiKTeX','Install Root');
    latexcmd = [latexpath '\miktex\bin\latex.exe -halt-on-error '...
               '-interaction nonstopmode <viewfile>.tex'];
    dvipscmd = [latexpath '\miktex\bin\dvips.exe -D600 -E* '...
               '-o<viewfile>.eps <viewfile>.dvi'];
  catch    % hoping the path variable is properly set
    latexcmd = ['latex.exe -halt-on-error '...
               '-interaction nonstopmode <viewfile>.tex'];
    dvipscmd = ['dvips.exe -D600 -E* '...
               '-o<viewfile>.eps <viewfile>.dvi'];
  end
  epstoolcmd = ['C:\Ghostgum\epstool\bin\epstool.exe '...
               '--bbox --copy --output '...
               '<filename>_final.eps <viewfile>.eps'];
  delcmd =     ['del <viewfile>.eps <viewfile>.dvi ',...
               '<viewfile>.aux <viewfile>.log ',...
               '<viewfile>.pfg'];
  gsviewcmd = 'C:\Ghostgum\gsview\gsview32.exe <filename>_final.eps&';
else % hoping the path variable is properly set
  latexcmd =   ['latex -halt-on-error '...
               '-interaction nonstopmode <viewfile>.tex'];
  dvipscmd =   ['dvips -D600 -E* '...
               '-o<viewfile>.eps <viewfile>.dvi'];
  epstoolcmd = ['epstool --bbox --copy --output '...
               '<filename>_final.eps <viewfile>.eps'];
  delcmd =     ['rm <viewfile>.eps <viewfile>.dvi ',...
               '<viewfile>.aux <viewfile>.log ',...
               '<viewfile>.pfg'];
  gsviewcmd =  'ghostview <filename>_final.eps&';
end

vers = version;
vers = eval(vers(1:3));
if vers < 6.5
  colorvalue=0;
else
  colorvalue=1;
end

   opt = struct(...
      'figno',{1},...
      'filename','unnamed',...
      'width',12,...
      'factor',0.8,...
      'scalefonts',1,...
      'keepfontprops',0,...
      'asonscreen',0,...
      'keepticklabels',0,...
      'mathticklabels',0,...
      'head',1,...
      'comment','',...
      'caption','',...
      'extrapicture',0,...
      'nzeros',3,...
      'verbose',0,...
      'figcopy',1,...
      'printcmd',['print(''-f<figurenumber>'',' ...
                      '''-depsc'',''-painters'','...
                      '''<filename.eps>'')'],...
      'package','graphicx',...
      'color',colorvalue,...
      'createview',0,...
      'viewfilename','unnamed_',...
      'processview',0,...
      'cmd1',latexcmd,...
      'cmd2',dvipscmd,...
      'cmd3',epstoolcmd,...
      'cmd4',delcmd,...
      'cmd5',gsviewcmd,...
      'cmd6','',...
      'cmd7','',...
      'cmd8','');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function updategui(LAPRINTHAN,LAPRINTOPT)
% update gui

set(LAPRINTHAN.figno,'string',num2str(LAPRINTOPT.figno))
set(LAPRINTHAN.filename,'string',LAPRINTOPT.filename)
% width, factor, scalefonts
if LAPRINTOPT.keepfontprops
   set(LAPRINTHAN.keepfontprops,'check','on')
else 
   set(LAPRINTHAN.keepfontprops,'check','off')
end
if LAPRINTOPT.asonscreen
   set(LAPRINTHAN.asonscreen,'check','on')
else 
   set(LAPRINTHAN.asonscreen,'check','off')
end
if LAPRINTOPT.keepticklabels
   set(LAPRINTHAN.keepticklabels,'check','on')
else 
   set(LAPRINTHAN.keepticklabels,'check','off')
end
if LAPRINTOPT.mathticklabels
   set(LAPRINTHAN.mathticklabels,'check','on')
else 
   set(LAPRINTHAN.mathticklabels,'check','off')
end
if LAPRINTOPT.head
   set(LAPRINTHAN.head,'check','on')
else 
   set(LAPRINTHAN.head,'check','off')
end
% comment, caption
if LAPRINTOPT.extrapicture
   set(LAPRINTHAN.extrapicture,'check','on')
else 
   set(LAPRINTHAN.extrapicture,'check','off')
end
% nzeros
if LAPRINTOPT.verbose
   set(LAPRINTHAN.verbose,'check','on')
else 
   set(LAPRINTHAN.verbose,'check','off')
end
if LAPRINTOPT.figcopy
   set(LAPRINTHAN.figcopy,'check','on')
else 
   set(LAPRINTHAN.figcopy,'check','off')
end
% printcmd
switch LAPRINTOPT.package
  case 'epsfig'
   set(LAPRINTHAN.package_epsfig,'check','on')
   set(LAPRINTHAN.package_graphicx,'check','off')
  case 'graphicx'
   set(LAPRINTHAN.package_epsfig,'check','off')
   set(LAPRINTHAN.package_graphicx,'check','on')
end
if LAPRINTOPT.color
   set(LAPRINTHAN.color,'check','on')
else 
   set(LAPRINTHAN.color,'check','off')
end
if LAPRINTOPT.createview
   set(LAPRINTHAN.createview,'check','on')
else 
   set(LAPRINTHAN.createview,'check','off')
end
% viewfilename
if LAPRINTOPT.processview
   set(LAPRINTHAN.processview,'check','on')
else 
   set(LAPRINTHAN.processview,'check','off')
end
% cmd1, cmd2, cmd3, cmd4, cmd5, cmd6, cmd7, cmd8

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function txt = helptext()
% help text
txt={...
'',...
['LAPRINT prints a figure for inclusion in LaTeX documents. ',...
'It creates an eps-file and a tex-file. The tex-file contains the ',...
'annotation of the figure such as titles, labels and texts. The ',...
'eps-file contains the non-text part of the figure and is called ',...
'by the tex-file. The main advantage of using LaPrint ',...
'is that the annotation can be neatly (e.g., including math ',...
'mode and fancy font constructs) set within LaTeX.'],...
'',...
'Prerequisites:',...
'~~~~~~~~~~~~~~',...
['Matlab 6.1 or above is required. To process the LaTeX file, a ',...
'LaTeX compiler (including the packages ''graphicx'' and ',...
'''psfrag'') and a dvi-to-postscript converter (like dvips) '...
'is required. Optional tools are a postscript-viewer ',...
'(like ghostview), a postscript bounding box converter ',...
'(like epstool) and the LaTeX packages color ',...
'and epsfig.'],...
'',...
'Installation:',...
'~~~~~~~~~~~~~',...
['LaPrint comes as a single m-file, which has to be placed  ',...
'somewhere in the Matlab search path. If you want LaPrint to ',...
'call LaTeX and friends, the (system dependent) executables have ',...
'to be defined using the GUI (see below).'],...
'',...
'An example to get started:',...
'~~~~~~~~~~~~~~~~~~~~~~~~~~',...
['It is recommended to switch off the Matlab TeX ',...
'interpreter before creating a graphics to be processed by ',...
'LaPrint:'],...
'  >> set(0,''DefaultTextInterpreter'',''none'')',...
'Create an example graphics using',...
'  >> figure(1), clf',...
'  >> plot([1 2])',...
'  >> xlabel(''$x$'')',...
'  >> ylabel(''A straight line $f(x)=\alpha x + \beta$'')',...
'  >> text(1.1,1.9,{''\textbf{This figure is not exiting.}'',...',...
'     ''(but it shows some features of \texttt{laprint})''})',...
['Note that the text uses LaTeX constructs like ''$.$'', ',...
'''\alpha'' and ''\textbf{}''. You can employ the full LaTeX ',...
'repertoire here.'],...
['Open the LaPrint graphical user interface (GUI) ',...
'(if you haven''t already done so), by typing'],...
'  >> laprint',...
['Check if the GUI points to Figure Number 1, ',...
'and save the graphics by pressing ''Go!''. ',...
'This creates the files ''unnamed.tex'' and ''unnamed.eps''. ',...
'These can be included in a LaTeX document as follows:'],...
'  % This is the LaTeX document testdoc.tex',...
'  \documentclass{article}',...
'  \usepackage{graphicx,color,psfrag}',...
'  \begin{document}',...
'  Here comes a Matlab figure created with \texttt{laprint}:\\',...
'  \input{unnamed}',...
'  \end{document}',...
['This document can be compiled with LaTeX (to create ',...
'''testdoc.dvi'') and converted to postscript (to create ',...
'''testdoc.ps''). The document ''testdoc.ps'' will contain the ',...
'Matlab graphics with LaTeX annotation. Observe that the ',...
'figure is 12cm wide and that the fonts are scaled to 80% ',...
'of their original size. This is the default behaviour of ',...
'LaPrint, which can be adjusted using ''Options'' in the ',...
'GUI menu bar (as will explained below).'],...
'',...
['Instead of using the GUI you can also call LaPrint ',...
'from the command line (or from an m-file) as follows:'],...
'  >> laprint(1,''unnamed'')',...
'',...
'This is what LaPrint does:',...
'~~~~~~~~~~~~~~~~~~~~~~~~~~',...
'Basically, LaPrint performs the following tasks:',...
' - Take a preliminary copy of the figure. ',...
' - In the preliminary figure, replace all text objects by tags.',...
[' - Save the preliminary figure (with tags) as an eps-file using ',...
'the Matlab ''print'' command.'],...
[' - Create a tex-file which calls the eps-file (using the ',...
'''graphicx'' package) and replaces ',...
'the tags by the original text (using the ''psfrag'' package).'],...
'',...
['It is instructive to have a look into the tex-file ',...
'(''unnamed.tex'' in the above example). ',...
'If your graphics contains huge amounts of LaTeX-code, then ',... 
'you might also consider editing the tex-file with your ',...
'favourate LaTeX editor. You have however to be carefull, ',...
'because LaPrint (using default settings) doesn''t care ',...
'overwriting files.'],...
'',...
'Using the LaPrint GUI: ',...
'~~~~~~~~~~~~~~~~~~~~~~',...
['The behaviour of LaPrint can be controlled by various settings ',...
'and options. Using the GUI, these can be set using the ''Options'' ',...
'entry in the menu bar. Using LaPrint from the command line, ' ,...
'these can be set by extra input arguments in the form of ',...
'option/value pairs. In the following, the options are explained ',...
'in some detail based on the GUI. Later, a table with the ',...
'command line option/value pairs is given.'],...
'',...
'In the main LaPrint window you can specify',...
['-- the number of the Matlab figure to be saved (this must be ',...
'the handle of an open Matlab window) and '],...
['-- the basename of the files to be saved (for instance, if ',...
'the basename is ''unnamed'', then ''unnamed.tex'' and ',...
'''unnamed.eps'' are created;).'],...
'',...
'Via the menu bar you can control the following settings:',...
'',...
'Options --> Sizes and Scalings ...',...
'',...
'This opens a window where you can specify ',...
'-- the width (in cm) of the graphics in the LaTeX document;',...
'-- a scaling factor and',...
'-- whether you want fonts to be scaled.',...
['The width controls the size of the graphics. Its height ',...
'is computed such that the ratio of width to height of the ',...
'figure on screen is retained. The factor controls the ',...
'''denseness'' of the graphics. For instance, if the width is ',...
'w=12 and the factor is f=0.8, then the graphics in the ',...
'eps-file will have width w/f=15 cm and the tex-file ',...
'scales it down to 12 cm. This means that lines become thinner ',...
'and fonts become smaller (as compared to w=12; f=1.0). ',...
'Good values for papers are f=0.8 to f=1.0, ',...
'and f=1.5 is a good value for presentations. ',...
'Switching font scaling off only scales the graphics. ',...
'You may want to experiment with some w/f/scalefont combinations ',...
'to find out your personal preference. '],...
'',...
'Options --> Translate Matlab Font Properties to LaTeX ',...
'',...
['This option can be switched on/off. When off, all text ',...
'will be set using the LaTeX font which is active while ',...
'entering the tex-file (Matlab font settings are ignored). When ',...
'on, Matlab font settings are translated to LaTeX font ',...
'settings.'],...
'',...
'Options --> Print Limits and Ticks as on Screen',...
'',...
['This option can be switched on/off. When on, the axes ',...
'limits and ticks are frozen. They appear in the LaTeX ',...
'document as on screen. When off, they are adapted by ',...
'Matlab.'],...
'',...
'Options --> Keep Tick Labels within eps File',...
'',...
['This option can be switched on/off. When on, the tick ',...
'labels aren''t replaced by their LaTeX equivalents. This is ',...
'useful for some 3D-plots.'],...
'',...
'Options --> Set Tick Labels in LaTeX Math Mode',...
'',...
['This option can be switched on/off. When on, the tick ',...
'labels are surrounded by a ''$''.'],...
'',...
'Options --> Equip the tex File with a Head',...
'',...
['This option can be switched on/off. When on, the tex-file ',...
'is equipped with a header with a bunch of comments (date, files, ',...
'example, comment text,...).'],...
'',...
'Options --> Comment in the Head of the tex File ...',...
'',...
['This opens a window where you can specify a comment to be ',...
'placed in the header of the tex file.'],...
'',...
'Options --> Place a LaTeX caption in the tex File ...',...
'',...
['This opens a window where you can enter a caption text. If this ',...
'caption text is nonempty, it is placed as a \caption{} ',...
'into the tex-file. Thus the text will appear in the LaTeX ',...
'document. In addition a \label{} is placed in the tex-file ',...
'which can be used to refer to the graphics. The label will ',...
'be fig: followed by the basename of the files, e.g., ',...
'\label{fig:unnamed}.'],...
'',...
'Options --> Place an Extra Picture in each Axes',...
'',...
['This option can be switched on/off. When on, each axes in the ',...
'figure is equipped with an empty LaTeX ''picture'' environment. ',...
'It can be used to place some additional material into the ',...
'figure by editing the tex-file.'],...
'',...
'Options --> Length of the psfrag Replacement Strings ...',...
'',...
['This opens a window where you can enter the length of the ',...
'psfrag tags. If you have huge amounts of text, the default ',...
'length of 3 might not suffice.'],...
'',...
'Options --> Call LaPrint in verbose mode',...
'',...
['This option can be switched on/off. When on, LaPrint issues ',...
'some messages and warns before overwriting files.'],...
'',...
'Options --> Copy Figure and Modify that Copy',...
'',...
['This option can be switched on/off. When on, LaPrint takes ',...
'a copy of the figure to be printed and places its tags into ',...
'that copy. When done, the copy is deleted. When off, the ',...
'figure is messed up by tags. It gets unusable, but you can see ',...
'what LaPrint is doing. Besides, there are bugs in the Matlab ',...
'''copyobj'' command. If these show up, this option is useful.'],...
'',...
'Options --> Matlab Print Command ...',...
'',...
['This opens a window where you can enter the Matlab command to ',...
'save the graphics in an eps-file. You can modify the standard ',...
'print command to include or remove options (like ''-loose'') ',...
'or employ a different command (like exportfig). '],...
'',...
'Options --> Matlab Graphics Package',...
'',...
'You can chose between ''graphicx'' and ''epsfig''.',...
'',...
'Options --> Use LaTeX ''color'' package',...
'',...
['This option can be switched on/off. When on, LaPrint places ',...
'color commands into the tex file to optain colored text.'],...
'',...
'Options --> View File ... --> Create a View File',...
'',...
['This option can be switched on/off. When on, LaPrint creates ',...
'a third file (the view-file), which is a complete LaTeX ',...
'document showing the graphics. You can process this file ',...
'with your favourate LaTeX- and dvi-to-postscript compiler. ',...
'This is useful to have a quick look at the result and to ',...
'create a futher eps-file containing everything (see below). ',...
'The process of compiling the view-file can be automated using ',...
'the options described below.'],...
'',...
'Options --> View File ... --> Name of the View File',...
'',...
['This opens a window where you can enter the name of the ',...
'view-file to be created.'],...
'',...
'Options --> View File ... --> Process the View File',...
'',...
['This option can be switched on/off. When on, LaPrint ',...
'calls the LaTeX compiler and its friends to process the ',...
'view file. The names of the executables to be used and ',...
'their syntax can be set using the following option. '],...
'',...
['Options --> View File ... --> Executables for processing ',...
'View File'],...
'',...
['This opens a window where you can enter the names of up to 8 ',...
'system commands to process the view-file. If you have less than 8 ',...
'programs, you can leave the some of the fields empty. In all ',...
'commands, LaPrint internally replaces the tag ''<viewfile>'' ',...
'by the basename of the viewfile and the tag <filename> by ',...
'the basename specified in the main LaPrint window. ',...
'In following example you have to add the paths, if the ',...
'commands are not in the system search path.'],...
'',...
'To create and view a ps document:',...
' cmd1:  latex <viewfile>.tex',...
' cmd2:  dvips -o<viewfile>.ps <viewfile>.dvi',...
' cmd3:  gsview32 <viewfile>.ps   (ghostview for Unix)',...
'',...
'',...
'Preferences:',...
'~~~~~~~~~~~~',...
['All options and settings of LaPrint can be ',...
'(internally and externally) stored ',...
'in ''Preferences''. Suppose that you have changed, via ',...
'the ''Options'' menu bar entry, the settings of LaPrint. ',...
'You can make these settings to your preferred (default) ',...
'settings by chosing'],...
'',...
'Preferences --> Set Preferences to Current Settings',...
'',...
['This means that future sessions of LaPrint load these ',...
'settings on startup. You can also manually reload these ',...
'settings by chosing'],...
'',...
'Preferences --> Get Preferences',...
'',...
['LaPrint has built-in (factory default) preferences, ',...
'which you see when using ',...
'LaPrint the first time. You can restore these defaults ',...
'by chosing'],...
'',...
'Preferences --> Get Factory Defaults',...
'',...
['If you want your personal preferences be completely removed ',...
'(switching back to factory defaults on startup), you should ',...
'chose'],...
'',...
'Preferences --> Remove Preferences',...
'',...
['If you have multiple projects running and want to use different ',...
'settings simultaneously, you can save/load preferences ',...
'to/from mat-files by chosing'],...
'',...
'Preferences --> Save Current Settings to a File ',...
'Preferences --> Load Settings from a File ',...
'',...
'These open a new window asking for the name of a .mat file.',...
'',...
'Using LaPrint from the command line:',...
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',...
['When using LaPrint from the command line (or from an m-file), ',...
'the following syntax is required:'],...
'',...
'  laprint(figno,filename)',...
'  laprint(figno,filename,opta,vala,optb,valb,..)',...
'',...
'where',...
'  figno        : integer, figure to be printed',...
'  filename     : string (character array), basename of files',...
'                 to be created',...
'  opta,vala,.. : option and value pairs, where opta is one',...
'                 of the following options and vala is',...
'                 the corresponding value.',...
'',...
['When calling LaPrint from the command line without ',...
'option/value pairs, it uses the same '],...
['settings/options as the GUI on startup. This means that ',...
'it uses'],...
['-- the factory default settings (if you havn''t ',...
'stored your personal preferences using the GUI) or '],...
'-- your personal preferences. ',...
'The factory default settings can be enforced by typing ',...
'  laprint(figno,filename,''options'',''factory'')',...
['These settings can be overwritten by option/value pairs ',...
'as explained in the following table.'],...
'',...
'option          |class/val.| remark',...
'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',...
'''width''         | <double> | width of the figure in the LaTeX',...
'                |          | document (in cm).',...
'''factor''        | <double> | factor by which the figure in ',...
'                |          | the LaTeX document is smaller than ',...
'                |          | the figure in the postscript file.',...
'''scalefonts''    |''on''/''off''| scales the fonts with the ',...
'                |          | figure (see option ''factor'').',...
'''keepfontprops'' |''on''/''off''| translates MATLAB font',... 
'                |          | properties (size, width, angle) into',...
'                |          | corresponding LaTeX font properties.',... 
'''asonscreen''    |''on''/''off''| prints ticks and lims ',...
'                |          | ''as on screen''.',...
'''keepticklabels''|''on''/''off''| keeps the tick labels within',...
'                |          | the eps-file (not using LaTeX).',...
'''mathticklabels''|''on''/''off''| tick labels are set in LaTeX',...
'                |          | math mode',...
'''head''          |''on''/''off''| places a commenting header in ',...
'                |          | the tex-file.',...
'''comment''       | <string> | places the comment <string> into',...
'                |          | the header of the tex-file.',...
'''caption''       | <string> | adds \caption{<string>} and',...
'                |          | \label{fig:<filename>} to the',...
'                |          | tex-file.',...
'''extrapicture''  |''on''/''off''| adds empty picture environments',...
'                |          | to the axes.',...
'''nzeros''        | <int>    | uses replacement strings of',...
'                |          | length <int> in the eps-file.',...
'''verbose''       |''on''/''off''| verbose mode; asks before',...
'                |          | overwriting files and issues some ',...
'                |          | more messages.',... 
'''figcopy''       |''on''/''off''| directly modifies the original',...
'                |          | figure.',...
'''printcmd''      | <string> | uses ''<string>'' as Matlab print',...
'                |          | command.',...
'''package''       | <string> | uses the LaTeX graphics package',...
'                |          | ''<string>''. Possible values are',...
'                |          | ''graphicx'' and ''epsfig''.',...
'''color''         |''on''/''off''| uses colored fonts (using the',... 
'                |          | LaTeX ''color'' package).',... 
'''createview''    |''on''/''off''| creates a view-file, which ',... 
'                |          | calls the tex-file.',...
'''viewfilename''  | <string> | Basename of the  view-file.',...
'''processview''   |''on''/''off''| processes the view-file ',... 
'                |          | by LaTeX and friends.',...
'''cmd1''          | <string> | 1st Command in the sequence of',...
'                |          | LaTeX and friends (enter an empty',...
'                |          | string to skip this command).',... 
'''cmd2''          | <string> | 2nd LaTeX/friend Command ',...
'''cmd3''          | <string> | 3rd LaTeX/friend Command ',...
'''cmd4''          | <string> | 4th LaTeX/friend Command ',...
'''cmd5''          | <string> | 5th LaTeX/friend Command ',...
'''cmd6''          | <string> | 6th LaTeX/friend Command ',...
'''cmd7''          | <string> | 7th LaTeX/friend Command ',...
'''cmd8''          | <string> | 8th LaTeX/friend Command ',...
'''options''       | <string> | This option can be used to ',...
'                |          | employ project-dependent ',... 
'                |          | preferences as follows:',... 
'                |          | 1) Save your preferences to a file ',... 
'                |          |    using the GUI:',... 
'                |          |    Preferences --> ',... 
'                |          |     Save Current Settings to a file',... 
'                |          | 2) Reload these preferences',... 
'                |          |    with laprint:',... 
'                |          |    >> laprint(1,''unnamed'',..',... 
'                |          |        ''options'',<string>)',... 
'                |          |    where <string> is the name of ',...
'                |          |    the mat-file with preferences.',...
'',...
'',...
' ...................... ENJOY ! .......................',...
'',...
};
