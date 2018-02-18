classdef pf2odfSolver < handle
    
  properties
    pf % poleFigure data       
  end
  
  properties (Dependent = true)
    CS
    SS
  end
  
  methods
    function obj = pf2odfSolver(varargin)
    end
      
    function CS = get.CS(solver)
      CS = solver.pf.CS;
    end
    
    function SS = get.SS(solver)
      SS = solver.pf.SS;
    end
    
  end
end

