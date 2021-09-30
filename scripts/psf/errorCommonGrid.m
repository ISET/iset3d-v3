function [relerr,abserr] = errorCommonGrid(x1,y1,x2,y2)

    minX = max(min(x1),min(x2));
    maxX = min(max(x1),max(x2));
    range = linspace(minX,maxX,1000);
  
    resampled1=interp1(x1,y1,range);
    resampled2=interp1(x2,y2,range);
 
    abserr=norm(resampled1-resampled2);
    relerr=abserr/norm(resampled1);
 
    relerr=rms((resampled1-resampled2)./resampled1)
end

