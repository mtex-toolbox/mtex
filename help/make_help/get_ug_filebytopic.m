function ug_file = get_ug_filebytopic(ug_files,topic)

ug_file = ug_files(~cellfun('isempty',strfind(ug_files,[topic '.m'])));

if isempty(ug_file)
  ug_file = ug_files(~cellfun('isempty',strfind(ug_files,[topic '.html'])));
end

if isempty(ug_file)
  if exist([topic '.m'],'file')
    ug_file = {[topic '.m']};
  end
end

if ~isempty(ug_file)
ug_file = ug_file{:};
end