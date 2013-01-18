function uninstall_template(template)

%install template
if ~isempty(template)
  template = fullfile(mtex_path,'templates',template);
  
  if exist(template) == 2
    delete(template);
  end
end