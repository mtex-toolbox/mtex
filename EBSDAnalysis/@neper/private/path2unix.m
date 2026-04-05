function filePath = path2unix(filePath)
% deals with the different file separators etc of Windows and Unix systems
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