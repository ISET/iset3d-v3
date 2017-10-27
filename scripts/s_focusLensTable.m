%% s_focusLensTable
%
% Make a table in which rows are lens, columns are distances, and entries are
% the focal length.  So, 
%
%   T(whichLens,dist) = focalDistance
%
%{
 vcNewGraphWin; 
 focalDistance(focalDistance < 0) = NaN;
 loglog(focalDistance');
 xlabel('Object distance'); ylabel('Focal length');
%}

%%  All the lenses in the pbrt2ISET directory

lensDir = fullfile(piRootPath,'data','lens');
lensFiles = dir(fullfile(lensDir,'2El*.dat'));

dist = logspace(0.5,5,10);

%% Calculate the focal distances

focalDistance = zeros(length(lensFiles),length(dist));

for ii=1:length(lensFiles)
    fname = fullfile(lensDir,lensFiles(ii).name);
    for jj=1:length(dist)
        focalDistance(ii,jj) = focusLens(lensFiles(ii).name,dist(jj));
    end
end

%%  It 

%%
