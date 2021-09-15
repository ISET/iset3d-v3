 %load('psfcloser.mat')




%% Select PSF centers
 data=oi{1}.data.photons(:,:,1);
 figure;
 imagesc(data)   
%  
 [centersX,centersY] = (getpts);
 centersX=round(centersX)'
 centersY=round(centersY)'


%%
close all

centersX = round([ 2229        2767        3297        2229        2765        3291])

centersY = round([2764        2768        2765        3296        3296        3286])

rangeRadius=30


visPSF(oi,centersX,centersY,rangeRadius)

%% Indpeendent verification of PSF
