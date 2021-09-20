function visPSF(oiList,centersX,centersY,rangeRadius)

range = @(x) [(x-rangeRadius):(x+rangeRadius)];
maxnorm=@(x)x/max(x);


nbOi=numel(oiList);
resolutionMicron = oiGet(oiList{1},'width spatial resolution','microns');
imageCenter = round(size(oiList{1}.data.photons(:,:,1))/2);


for p=1:numel(centersX)
figure(p);clf; hold on,

for i=1:nbOi
    oi = oiList{i};
    data=oi.data.photons(range(centersX(p)),range(centersY(p)),1);
            slice=maxnorm(data(round(end/2),:));
    % Choose first OI as the reference to determine x axis
    if(i==1)
        index=find(slice==1);
        xax   = ([1:size(data,2)]-index)*resolutionMicron;
    end
    
    subplot(2,nbOi,i);
    imagesc(xax,xax,data)
    axis equal
    title(oi.name)
    
    subplot(2,2,3:4); hold on;


    h(i)=plot(xax, slice);
    
    distOffAxis = norm([centersX(p) centersY(p)]-imageCenter)*resolutionMicron;
    title(['Peak Normalized PSF: ' num2str(distOffAxis) ' \mu m off-axis'])
 
    xlabel('\mu m')
    
    oiLabels{i}=oi.name;
end

   legend(h,oiLabels)   
end

autoArrangeFigures

end

