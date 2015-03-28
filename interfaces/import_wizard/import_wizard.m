function import_wizard( varargin )


if check_option(varargin,'EBSD')
  select = 2;
elseif check_option(varargin,'ODF')
  select = 3;
elseif check_option(varargin,'tensor')
  select = 4;
else
  select = 1;
end

api.presetDataImport    = select;
api.isPublishMode       = getMTEXpref('generatingHelpMode');

if check_option(varargin,'test')
  test_wizard_export(api,varargin{:});
  return
end



api = WizardDataApi(api);
api = WizardEmptyGUIApi(api);
api = WizardProgressApi(api,@pageImportData);
api.initProgressApi();




function test_wizard_export(api,varargin)


api = WizardDataApi(api);

% testcases

switch lower(get_option(varargin,'test',''))
  case '3d'
    
    api.loadDataFiles(1,fullfile(mtexDataPath,'EBSD','3dData','S00.ang'))
    api.loadDataFiles(1,fullfile(mtexDataPath,'EBSD','3dData','S01.ang'))
    api.loadDataFiles(1,fullfile(mtexDataPath,'EBSD','3dData','S02.ang'))
    api.Export.setOptEBSD('is3d',true);
    api.Export.setOptEBSD('Z',num2cell(1:3));
    
  case 'ebsd'
    
    api.loadDataFiles(1,fullfile(mtexDataPath,'EBSD','data.ctf'))
    
  case 'odf'
    
    api.loadDataFiles(2,fullfile(mtexDataPath,'ODF','odf.mtex'))
    
  case 'pf'
    
    api.loadDataFiles(4,fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv'));
    api.loadDataFiles(4,fullfile(mtexDataPath,'PoleFigure','dubna','Q(02-21)_amp.cnv'));
    api.loadDataFiles(4,fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-20)_amp.cnv'));
    
    
    data = api.getData();
    
    data{1} = set(data{1},'CS',crystalSymmetry('trigonal'));
    
    api.setData(data);
    
  case 'bg'
    
    api.loadDataFiles(4,fullfile(mtexDataPath,'PoleFigure','dubna','Q(02-21)_amp.cnv'));
    api.loadDataFiles(5,fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-20)_amp.cnv'));
    
  case 'def'
    
    api.loadDataFiles(4,fullfile(mtexDataPath,'PoleFigure','dubna','Q(02-21)_amp.cnv'));
    api.loadDataFiles(5,fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-20)_amp.cnv'));
    api.loadDataFiles(6,fullfile(mtexDataPath,'PoleFigure','dubna','Q(02-21)_amp.cnv'));
    api.loadDataFiles(7,fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-20)_amp.cnv'));
  
  case 'lcp'
    
    api.loadDataFiles(4,fullfile(mtexDataPath,'PoleFigure','BearTex','Test_2.XPa'));
    api.loadDataFiles(4,fullfile(mtexDataPath,'PoleFigure','beartex.XPa'));
 
  otherwise
    
    api.loadDataFiles(4,fullfile(mtexDataPath,'PoleFigure','dubna','Q(02-21)_amp.cnv'));
    
    api = WizardEmptyGUIApi(api);
    api = WizardProgressApi(api,@pageImportData);
    api.initProgressApi();

    for j = 1:7
      pause(.5)
      api.nextCallback();
      snapnow;
    end
    
    close(api.hFigure);
    
    return
    % end
    
    % api = WizardProgressApi(api,@(a) pageCS(a,3));
    % api = WizardProgressApi(api,@pageKernel);
    % api = WizardProgressApi(api,@page3dEBSD);
    % api = WizardProgressApi(api,@pageFinish);
    
end


WizardFinish(api)

% api = WizardProgressApi(api,@(a) pageCS(a,3));
% api = WizardProgressApi(api,@pageKernel);
% api = WizardProgressApi(api,@page3dEBSD);
% api = WizardProgressApi(api,@pageFinish);


