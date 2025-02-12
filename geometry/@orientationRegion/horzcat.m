 function oR = horzcat(varargin)
 % [oR1,oR2]
 
 oR = varargin{1};
 
 for n = 2:numel(varargin)
   oR.N = [oR.N(:);varargin{n}.N(:)];
 end
 
 oR = oR.cleanUp;
  
 end
