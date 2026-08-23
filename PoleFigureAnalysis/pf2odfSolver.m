classdef pf2odfSolver < handle
% an abstract class representing solvers for the pole figure inversion
%
% Reconstructing an ODF from @PoleFigure data is an ill posed inverse
% problem. This is the interface calcODF drives; the only implementation is
% @MLSSolver, the modified least squares solver.
%
% Syntax
%   odf = calcODF(pf)
%   solver = MLSSolver(pf);
%   odf = solver.calcODF
%
% Class Properties
%  pf     - the @PoleFigure data
%  CS, SS - crystal and specimen @symmetry of pf
%
% Derived Classes
%  @MLSSolver - modified least squares, the MTEX default
%
% See also
% MLSSolver PoleFigure/calcODF PoleFigure2ODF
%
    
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

