function scrPrnt(silent,mode,txt)
% the progress lines an exporter prints

if silent, return; end

switch mode
  case 'SegmentStart'
    fprintf('\n------------------------------------------------------\n     %s \n------------------------------------------------------\n',txt);
  case 'Step'
    fprintf(' -> %s\n',txt);
  case 'SubStep'
    fprintf('    - %s\n',txt);
end

end
