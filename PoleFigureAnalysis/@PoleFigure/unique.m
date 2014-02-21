function pf = unique(pf)
% remove dublicated points in a polefigure

for ip = 1:pf.numPF
      
  [pf.allR{ip},ndx] = unique(pf.allR{ip});
    
  pf.allI{ip} = pf.allI{ip}(ndx);
    
end
