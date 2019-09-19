function api = WizardDataApi( api )


% data api
api.loadDataFiles         = @loadData;
api.setFiles              = @setFiles;
api.getFiles              = @getFiles;
api.setData               = @setData;
api.getData               = @getData;
api.getDataTransformed    = @getDataTransformed;
api.hasData               = @hasData;
api.clearAllData          = @clearData;
api.getDataType           = @getDataType;
api.setWorkpath           = @setWorkpath;
api.getWorkpath           = @getWorkpath;


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

    Export.interfaceOptions = delete_option(opts,'wizard');

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


  function setWorkpath(path)

    Options.workpath = path;

  end

  function path = getWorkpath()

    path = Options.workpath;

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


  function data = getDataTransformed()

    slot = getDataType();
    data = Data(slot);

    slotAlias = {'EBSD','ODF','Tensor','PoleFigure',...
      'Background','Defoccusing','DefoccusingBackground'};

    dataAlias = slotAlias(slot);

    switch dataAlias{1}
      case slotAlias{1}
        data = applyZValues(data);
      case slotAlias{4}
        data = applyPFCorrection(data,dataAlias);
      otherwise
        data = [data.obj{:}];
    end

    data = applyRotation(data);




    function data = applyRotation(data)

      rotOpts = {'','keepXY','keepEuler','keepEuler','keepXY'};

      if getSS('rotOption') > 3
        switch api.Export.getInterface()
          case {'ang','osc'}
            rot = rotation.byAxisAngle(xvector+yvector,180*degree);
          case {'ctf','crc'}
            rot = rotation.byAxisAngle(xvector,180*degree);
        end
      else
        rot = getSS('rotate');
      end

      data = rotate(data,rot,rotOpts{getSS('rotOption')});

    end

    function data = applyZValues(data)

      data = data.obj;

      if getEBSD('is3d')

        % TODO
        data(:) = cellfun(@(x,z) set(x,'z',z*ones(numel(x),1)),...
          data(:),getEBSD('Z'),'UniformOutput',false);

      else

        data = [data{:}];
        data.unitCell = calcUnitCell([data.x(:),data.y(:)]);

      end



    end

    function data = applyPFCorrection(data,alias)

      for k=1:numel(data)
        data(k).obj = [data(k).obj{:}];
      end

      try
        ndata  = [alias(2:end);{data(2:end).obj}];
        data = correct(data(1).obj,ndata{:});
      catch e
        errordlg(e.message)
      end

    end

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

    Options.workpath     = getMTEXpref('ImportWizardPath');

    Options.SS.direction = xaxis + 4*(zaxis-1);
    Options.SS.rotate    = rotation.byEuler(0,0,0,'ZXZ');
    Options.SS.rotOption = 1;
    Options.SS.text      = '';

    Options.ODF.psi      = deLaValleePoussinKernel('halfwidth',10*degree);
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
          feval([datatype '.load'],files(k),interf{:},options{:},'wizard');

        assertCS(newData);
      end
    catch e
      errordlg(e.message);
      return;
    end

    setInterface(interface);
    setInterfaceOptions(options);

    setFiles(newFiles,type);
    setData (newData,type);

    setDataDefaultOptions();

    function assertCS(data)

      if isa(data{1},'EBSD')
        CS = {};  map = [];
        for j=1:numel(data)
          CS  = [CS data{j}.CSList];
          map = [map;data{j}.phaseMap];
        end

        [map,b,c] = unique(map);
        for j=1:max(c)
          mapCS = CS(c == j);
          for l=1:numel(mapCS)-1
            if mapCS{l} ~= mapCS{l+1}
              error('Symmetry mismatch in the EBSD phasemap, I won''t do that!');
            end
          end
        end

      else

        for l=1:numel(data)-1
          if data{l}.CS ~= data{l+1}.CS
            error('Symmetry mismatch in the EBSD phasemap, I won''t do that!');
          end
        end

      end

    end

    function setDataDefaultOptions()

      switch datatype
        case 'ODF'
          if check_option(options,'interp')
            setODF('method',false);
          else
            setODF('method',true);
          end
        case 'EBSD'
          switch interface
            case {'ang','ctf','crc','osc'}
              setSS('rotOption',5);
          end
      end
    end

  end


end
