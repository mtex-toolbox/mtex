function s=toolboxdir(dirname)
% return the root directory for specified toolbox  
   
s=fullfile(matlabroot,'toolbox', dirname);
    
if ispc, s=lower(s); end
    
