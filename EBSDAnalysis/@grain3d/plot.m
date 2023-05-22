function plot(this,GrainIDs)
      idPoly=this.I_CF(GrainIDs,:);
      Poly=this.poly(logical(idPoly));
      idPoly=nonzeros(idPoly);
      Poly(idPoly==-1)=cellfun(@(c) fliplr(c),Poly(idPoly==-1),'UniformOutput',false);
      drawMesh(this.V,Poly, 'FaceColor','g')
      drawFaceNormals(this.V,Poly)
    end