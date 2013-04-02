function api = WizardDataApi( api )


% data api
api.loadDataFiles         = @loadData;
api.setFiles              = @setFiles;
api.getFiles              = @getFiles;
api.setData               = @setData;
api.getData               = @getData;
api.hasData               = @hasData;
api.clearAllData          = @clearData;
api.getDataType           = @getDataType;

% data export api
api.Export.setWorkspaceName      = @setVarname;
api.Export.getWorkspaceName      = @getVarname;
api.Export.setGenerateScriptFile = @setGenerateScriptFile;
api.Export.getGenerateScriptFile = @getGenerateScriptFile;
api.Export.setInterface          = @setInterface;
api.Export.getInterface          = @getInterface;
api.Export.setInterfaceOptions   = @setInterfaceOptions;
api.Export.getInterfaceOptions   = @getInterfaceOptions;
% api.Export.setOptions            = @setOtherOpions;
% api.Export.getOptions            = @getOtherOpions;

api.Export.setOptSpecimen        = @setSS;
api.Export.getOptSpecimen        = @getSS;
api.Export.setOptODF             = @setODF;
api.Export.getOptODF             = @getODF;
api.Export.setOptEBSD            = @setEBSD;
api.Export.getOptEBSD            = @getEBSD;



% storage variables
Export   = struct;
Options  = struct;
Data     = struct;
% init storage
api.clearAllData();


  function setInterface(interf)
    
    Export.interface =  interf;
    
  end

  function interf = getInterface()
    
    interf = Export.interface;
    
  end

  function setInterfaceOptions(opts)
    
    Export.interfaceOptions = opts;
    
  end

  function opts = getInterfaceOptions()
    
    opts = Export.interfaceOptions;
    
  end

  function setSS(vname,opts)
    
    if nargin > 0
      Options.SS.(vname) = opts;
    else
      Options.SS = vname;
    end
    
  end

  function opts = getSS(vname)
    
    if nargin > 0
      opts = Options.SS.(vname);
    else
      opts = Options.SS;
    end
    
  end

  function setODF(vname,opts)
    
    if nargin > 0
      Options.ODF.(vname) = opts;
    else
      Options.ODF = vname;
    end
    
  end

  function opts = getODF(vname)
    
    if nargin > 0
      opts = Options.ODF.(vname);
    else
      opts = Options.ODF;
    end
    
  end

  function setEBSD(vname,opts)
    
    if nargin > 0
      Options.EBSD.(vname) = opts;
    else
      Options.EBSD = vname;
    end
    
  end

  function opts = getEBSD(vname)
    
    if nargin > 0
      opts = Options.EBSD.(vname);
    else
      opts = Options.EBSD;
    end
    
  end

  function setGenerateScriptFile(state)
    
    Export.Script = state;
    
  end

  function state = getGenerateScriptFile
    
    state = Export.Script;
    
  end

  function setVarname(name)
    
    Export.VarName = name;
    
  end

  function name = getVarname()
    
    name = Export.VarName;
    
  end

  function f = getFiles(slot)
    
    if nargin < 1
      slot = getDataType();
      slot = slot(1);
    end
    
    f = Data(slot).files;
    
  end

  function setFiles(f,slot)
    
    if nargin < 1
      slot = getDataType();
      slot = slot(1);
    end
    
    Data(slot).files = f;
    
  end

  function setData(data,slot)
    
    if nargin < 2
      slot = getDataType();
      slot = slot(1);
    end
    
    Data(slot).obj = data;
    
    if isempty(getDataType())
      clearData();
    end
    
  end

  function data = getData(slot)
    
    if nargin < 1
      slot = getDataType();
      slot = slot(1);
    end
    
    data = Data(slot).obj;
    
  end

  function type = getDataType()
    
    type = find(~cellfun('isempty',{Data.obj}));
    
  end

  function b = hasData()
    
    b = any(~cellfun('isempty',{Data.files}));
    
  end

  function clearData()
    
    Data        = struct;
    Data.files  = {};
    Data.obj    = {};
    % copy seven
    Data(1:7)   = Data;
    
    
    % init export storage
    Export.Script             = true;
    Export.VarName            = '';
    Export.interface          = [];
    Export.interfaceOptions   = {};
    
    xaxis = NWSE(getMTEXpref('xAxisDirection'));
    zaxis = UpDown(getMTEXpref('zAxisDirection'));
    
    Options.SS.direction = xaxis + 4*(zaxis-1);
    Options.SS.rotate    = rotation('Euler',0,0,0,'ZXZ');
    Options.SS.rotOption = 1;
    Options.SS.text      = '';
    
    Options.ODF.psi      = kernel('de la valle','halfwidth',10*degree);
    Options.ODF.exact    = true;
    Options.ODF.approx   = 5;
    Options.ODF.method   = true;
    
    Options.EBSD.is3d    = false;
    Options.EBSD.Z       = [];
    
  end

  function loadData(type,files)
    
    datatype  = {'EBSD','ODF','Tensor',...
      'PoleFigure','PoleFigure','PoleFigure','PoleFigure'};
    
    datatype  = datatype{type};
    files     = ensurecell(files);
    
    interface = getInterface();
    options   = getInterfaceOptions();
    
    if ~isempty(interface)
      interf = {'interface',interface};
    else
      interf = {};
    end
    
    newFiles  = getFiles(type);
    newData   = getData(type);
    
    offset    = numel(newFiles);
    
    try
      for k=1:numel(files)
        newFiles{offset+k} = files{k};
        [newData{offset+k},interface,options] = ...
          feval(['load' datatype],files(k),interf{:},options{:});
      end
    catch e
      errordlg(e.message);
      return;
    end
    
    setInterface(interface);
    setInterfaceOptions(options);
    
    setFiles(newFiles,type);
    setData (newData,type);
    
    
    switch datatype
      case 'ODF'
        if check_option(options,'interp')
          setODF('method',false);
        else
          setODF('method',true);
        end
      case 'EBSD'
        switch interface
          case 'ang'
            setSS('rotate',rotation('euler',90*degree,180*degree,0*degree,'ZXZ'));
            setSS('rotOption',3);
            setSS('text',['Warning: ' ...
              'The ang format usually uses different conventions for '...
              'the spatial and the Euler angle reference frame. ' ...
              'The default rotation corrects for this']);
          case 'ctf'
            setSS('rotate',rotation('euler',180*degree,0*degree,0*degree,'ZXZ'));
            setSS('rotOption',3);
            setSS('text',['Warning: ' ...
              'The ctf format usually uses different conventions for '...
              'the spatial and the Euler angle reference frame. ' ...
              'The default rotation corrects for this.']);
        end
    end
  end


end
