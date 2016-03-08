function opt = extractOptions(optList,opt)
% extract options from option list
%
% Input
%  optList - Cell Array
%  opt     - struct
%
% Output
%  opt     - struct
%
% See also
% getOption setOption addOption

fnames = fieldnames(opt);
for k = 1:numel(fnames)

  fn = fnames{k};
  
  if check_option(optList,fn)
  
    if islogical(opt.(fn))

      v = get_option(optList,fn,'logical');
      
      opt.(fn) = all(v);
      
      
    else
      
      opt.(fn) = get_option(optList,fn);
      
    end
  end
end