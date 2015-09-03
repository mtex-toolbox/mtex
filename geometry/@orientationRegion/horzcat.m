 function oR = horzcat(varargin)
 
 oR = varargin{1};
 
 for n = 2:numel(varargin);
   oR.N = [oR.N(:);varargin{n}.N(:)];
 end
 
 oR = oR.cleanUp;
  
 end
