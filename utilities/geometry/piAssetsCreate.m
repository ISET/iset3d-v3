function obj = piAssetsCreate(thisR, varargin)
% Add 
p = inputParser;
p.addRequired('renderRecipe',@(x)isequal(class(x),'recipe'));
p.addParameter('nCars',1);
p.addParameter('nTrucks',0);
p.addParameter('nPeople',0);
p.addParameter('nBuses',0);
p.addParameter('nCyclist',0);

p.parse(varargin{:});
inputs = p.Results;

obj = [];
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
    
    % list Car session
    
    % Choose one aquisition or mutiple? zip 
    % desDir folder or file?
    % unzip it
    thisR = piRead(filename,'version',3);
    piMaterialGroupAssign(thisR);
    geometry = piGeometryRead(thisR);
    obj(ii).material =thisR.materials.list;
    obj(ii).geometry = geometry;
    cnt = cnt+1;
end



end
function coloro=piColorPick(varagin)
% Color library, what is the common color 
p = inputParser;
p.addParameter()
end