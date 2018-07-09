function assets = piAssetsCreate(thisR, varargin)
% Create and combine assets using base information from a recipe
%
% Inputs
%  thisR - A rendering recipe
%
% Optional key/value parameters
%   nCars
%   nTrucks
%   nPeople
%   nBuses
%   nCyclist
%   scitran
%
% Returns
%   assets - Struct with the asset geometries and materials
%
% Zhenyi, Vistasoft Team, 2018

%%
p = inputParser;

p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
p.addParameter('nCars',1);
p.addParameter('nTrucks',0);
p.addParameter('nPeople',0);
p.addParameter('nBuses',0);
p.addParameter('nCyclist',0);
p.addParameter('scitran','',@(x)(isa(x,'scitran')));

p.parse(thisR,varargin{:});
inputs = p.Results;
st = p.Results.scitran;
if isempty(st), st = scitran('stanfordlabs'); end

hierarchy = st.projectHierarchy('Computer Graphics','project id','5b3eac08d294db0016bb1a2b');
% projects = st.search('project','project label exact','Computer Graphics')
assets = [];
cnt = 1;

%% Cars
% Create Assets obj struct
% Download random cars from flywheel, reuse some of the cars as intances
% if the cars required are less then what we have on the flywheel. 
% Obj Instance should be used, but better with different color for carbody. 
for ii=1:inputs.nCars

    currentClass = 'car';
    nClass = length(assets.(currentClass));
    
    objects(cnt).class = currentClass;
    objects(cnt).id = randi(nClass);
    % Download a random car obj from flywheel car session
    
    % list the acquisition labels in the first session
    whichSession = 1;
    stPrint(hierarchy.acquisitions{whichSession},'label','')
    file = st.search('file',...
        'session label exact','spaceship',...
        'acquisition label contains','Car',...
        'file name contains','obj');
    fname     = fullfile(stRootPath,'local','myCar.obj');
    localFile = st.fileDownload(file{1},'destination',fname);
    
    % Example of how to randomly select acquisitions from a specific
    % session
    whichSession = 1;
    nAcqs = length(hierarchy.acquisitions{whichSession});
    nSamples = 2;
    r = randi(nAcqs,[nSamples,1]);   % Column veftor of random integers
    
    % Choose one aquisition or mutiple? zip 
    % desDir folder or file?
    % unzip it
    thisR = piRead(filename,'version',3);
    piMaterialGroupAssign(thisR);
    geometry = piGeometryRead(thisR);
    assets(ii).material =thisR.materials.list;
    assets(ii).geometry = geometry;
    cnt = cnt+1;
end



end
function coloro=piColorPick(varagin)
% Color library, what is the common color 
p = inputParser;
p.addParameter()
end