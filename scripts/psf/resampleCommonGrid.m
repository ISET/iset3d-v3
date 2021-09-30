function [resampled] = resampleCommonGrid(xorig,yorig,xtarget)

      
    resampled=interp1(xorig,yorig,xtarget);
    resampled(isnan(resampled))=0;
    
end

