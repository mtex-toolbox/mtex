function pos = cBarSize(mtexFig)

pos = get(mtexFig.cBarAxis(1),'position');
pos = pos(3:4);
pos(pos==max(pos)) = 0;
      
try
  tiPos = get(mtexFig.cBarAxis(1),'tightInset');
  tiPos = tiPos(1:2) + tiPos(3:4);
        
catch
  tiPos = [2.5,1.5]*get(mtexFig.cBarAxis(1),'FontSize');
end
pos(pos>0) = pos(pos>0) + tiPos(pos>0);

end
