function filePath = path2unix(filePath)
% deals with the different fileseperators etc of Windows and unix systems
  if ~strcmp(computer,'PCWIN64')
    return
  else
    filePath(1) = lower(filePath(1));
    filePath(filePath == ':') = []; 
    filePath(filePath == '\') = '/';
    
    if ~startsWith(filePath,'/mnt/')
      filePath = ['/mnt/' filePath];
    end
  end
end