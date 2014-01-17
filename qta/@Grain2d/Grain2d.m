classdef Grain2d < GrainSet
% constructor for a 2d-GrainSet
%
% *Grain2d* represents 2d grains. a *Grain2d* represents grains and grain
% boundaries spatially and topologically. It uses formally the class
% [[GrainSet.GrainSet.html,GrainSet]].
%
% Syntax
%   grains = Grain2d(boundaryEdgeOrder,ebsd)
%
% Input
%  grainSet - @GrainSet
%  ebsd - @EBSD
%
% See also
% EBSD/calcGrains GrainSet/GrainSet Grain3d/Grain3d


  properties
    boundaryEdgeOrder
  end
  
  methods
    function obj = Grain2d(gs,varargin)
          
      x_D = [gs.ebsd.prop.x(:),gs.ebsd.prop.y(:)];
      
      gs.I_FDext = EdgeOrientation(gs.I_FDext,gs.F,gs.V,x_D);
      gs.I_FDint = EdgeOrientation(gs.I_FDint,gs.F,gs.V,x_D);
               
      obj = obj@GrainSet(gs,varargin{:});      
      obj.boundaryEdgeOrder = BoundaryFaceOrder(gs.D,gs.F,gs.I_FDext,gs.I_DG);

      
      function I_ED = EdgeOrientation(I_ED,E,x_V,x_D)
        % compute the orientaiton of an edge -1, 1

        [e,d] = find(I_ED);

        % in complex plane with x_D as point of orign
        e1d = complex(x_V(E(e,1),1) - x_D(d,1), x_V(E(e,1),2) - x_D(d,2));
        e2d = complex(x_V(E(e,2),1) - x_D(d,1), x_V(E(e,2),2) - x_D(d,2));

        I_ED = sparse(e,d,sign(angle(e1d./e2d)),size(I_ED,1),size(I_ED,2));

      end
      
      function b = BoundaryFaceOrder(D,F,I_FD,I_DG)

        I_FG = I_FD*I_DG;
        [i,d,s] = find(I_FG);

        b = cell(max(d),1);

        onePixelGrain = full(sum(I_DG,1)) == 1;
        [id,jg] = find(I_DG(:,onePixelGrain));
        b(onePixelGrain) = D(id);
        % close single cells

        for k = find(onePixelGrain), b{k} = [b{k} b{k}(1)]; end
        % b(onePixelGrain) = cellfun(@(x) [x x(1)],  b(onePixelGrain),...
        %   'UniformOutput',false);

        cs = [0 cumsum(full(sum(I_FG~=0,1)))];
        for k=find(~onePixelGrain)
          ndx = cs(k)+1:cs(k+1);
  
          E1 = F(i(ndx),:);
          s1 = s(ndx); % flip edge
          E1(s1>0,[2 1]) = E1(s1>0,[1 2]);
  
          b{k} = EulerCycles(E1(:,1),E1(:,2));
  
        end

        for k=find(cellfun('isclass',b(:)','cell'))
          boundary = b{k};
          [~,order] = sort(cellfun('prodofsize', boundary),'descend');
          b{k} = boundary(order);
        end

      end
    
    end
  end


  
  
end




