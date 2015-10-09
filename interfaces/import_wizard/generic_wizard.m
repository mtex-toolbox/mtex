function values = generic_wizard(varargin)



api.Data     = get_option(varargin,'data',rand(1000,7));
api.Header   = get_option(varargin,'header','i am a header');
api.Columns  = get_option(varargin,'columns','');
  
if size(api.Columns,2) ~= size(api.Data,2)
  api.Columns = cellfun(@(x) ['Column' num2str(x)], ...
    num2cell(1:size(api.Data,2)),'UniformOutput',false);
end

api.Type     = get_option(varargin,'type','EBSD');

api.isPublishMode       = getMTEXpref('generatingHelpMode');

p = get(0,'MonitorPositions');
api = WizardEmptyGUIApi(api,'PageHeight',min(2/3*p(1,4),600));
api = GenericApi(api);

waitfor(api.hFigure);


values = api.getOptions();

end
