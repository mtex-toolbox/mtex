/* MyMEXFunction
 * c = grainsFloodFill(diffOri_row, diffOri_col, phase, threshold);
 * goes through the EBSD map, assigns grainId to all pixels
*/
#define JC_VORONOI_IMPLEMENTATION
// If you wish to use doubles
#define JCV_REAL_TYPE double
#define JCV_FABS fabs
#define JCV_ATAN2 atan2
#define JCV_CEIL ceil
#define JCV_FLOOR floor
#define JCV_FLT_MAX 1.7976931348623157E+308

#include "mex.hpp"
#include "mexAdapter.hpp"
#include "jc_voronoi.h"

using namespace matlab::data;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {
    // Get array factory
    ArrayFactory factory;
    std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();

public:
    void operator()(ArgumentList outputs, ArgumentList inputs) {

        auto X = std::move(inputs[0]);
        int NPOINT = (int) X.getDimensions()[0];

        jcv_diagram diagram;
        jcv_point* points = (jcv_point*) malloc(sizeof(jcv_point)*NPOINT);
        
        memset(&diagram, 0, sizeof(jcv_diagram));
        
        for (int i=0; i<NPOINT; i++) {
            points[i].x = X[i][0];
            points[i].y = X[i][1];
        }
      
        jcv_diagram_generate(NPOINT,(const jcv_point *)points, 0, 0, &diagram);      
        
        std::vector<double> Vx, Vy;
        Vx.reserve(5*NPOINT);
        Vy.reserve(5*NPOINT);
        std::vector<int>  E1, E2 ,I_ED1,I_ED2;
        E1.reserve(3*NPOINT);
        E2.reserve(3*NPOINT);
        I_ED1.reserve(5*NPOINT);
        I_ED2.reserve(5*NPOINT);
        jcv_delauney_iter delauney;
        jcv_delauney_begin( &diagram, &delauney );
        jcv_delauney_edge delauney_edge;
        while (jcv_delauney_next( &delauney, &delauney_edge ))
        {
            if (delauney_edge.sites[0] && delauney_edge.sites[1])
            {
                Vx.push_back(delauney_edge.edge->pos[0].x);
                Vy.push_back(delauney_edge.edge->pos[0].y);
                E1.push_back(Vx.size());

                Vx.push_back(delauney_edge.edge->pos[1].x);
                Vy.push_back(delauney_edge.edge->pos[1].y);
                E2.push_back(Vx.size());
                              
                I_ED1.push_back((int)E1.size());
                I_ED2.push_back(delauney_edge.sites[0]->index+1);
                I_ED1.push_back((int)E1.size());
                I_ED2.push_back(delauney_edge.sites[1]->index+1);

            }
        }
        jcv_diagram_free(&diagram);

        outputs[0] = factory.createArray(ArrayDimensions{(size_t)Vx.size(),1},Vx.begin(),Vx.end());
        outputs[1] = factory.createArray(ArrayDimensions{(size_t)Vy.size(),1},Vy.begin(),Vy.end());
        outputs[2] = factory.createArray(ArrayDimensions{(size_t)E1.size(),1},E1.begin(),E1.end());
        outputs[3] = factory.createArray(ArrayDimensions{(size_t)E2.size(),1},E2.begin(),E2.end());
        outputs[4] = factory.createArray(ArrayDimensions{(size_t)I_ED1.size(),1},I_ED1.begin(),I_ED1.end());
        outputs[5] = factory.createArray(ArrayDimensions{(size_t)I_ED2.size(),1},I_ED2.begin(),I_ED2.end());

      free(points);
    }
};

