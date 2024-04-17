function makeRelease

ver = strrep(lower(getMTEXpref('version')),' ','-');
rDir = fullfile(mtex_path,'..','releases',ver);
zipName = [rDir,'.zip'];

if ~strcmpi(input(['Do you really want to release ' ver '? Y/N [N]:'],'s'),'Y')
  return;
end
  
unix(['rm -rf ',rDir]);
unix(['cp -R ' mtex_path ' ' rDir]);

rmList = {'doc/makeDoc/tmp', 'myToken.txt', 'data/*.mat' '.git*' 'data/EBSD/*'};
for rd = rmList 
  unix(['rm -rf ' rDir filesep char(rd)]); 
end

if any(strfind(ver,'beta'))
  unix(['rm -rf ' rDir filesep 'doc/html/*']);
  mkdir([rDir filesep 'doc/html/helpsearch-v3/']);
end

unix(['chmod -R a+rX ' rDir]);

% delete backup files
unix(['find ' rDir ' -name ''*~'' -or -name ''*.log'' -or -name ''*.o'' '...
  '-or -name ''*.orig'' -or -name ''.directory'' | xargs /bin/rm -rf']);

% delete old zip
unix(['rm -rf ' rDir '.zip']);

% create new zip
disp('compressing release ...')
zip(zipName,rDir);


disp('Authenticate at Github ...')
unix('terminator -e "gh auth login"');
% gh auth login

%doRelease = ['gh release create ' ver ' ' zipName ' -t "' getMTEXpref('version') '"'];
doRelease = ['gh release create ' ver ' ' zipName];
if any(strfind(ver,'beta')), doRelease = [doRelease,' -p']; end

disp('uploading release to GitHub ...')
unix(['terminator -e "' doRelease '"']);

end
