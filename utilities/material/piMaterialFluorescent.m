function thisR = piMaterialFluorescent(thisR, matName, varargin)
% Function to add fluorescent material(s)
%   
%% Parse input

p = inputParser;

vFunc = @(x)(isequal(class(x),'recipe'));
p.KeepUnmatched = true;
p.addRequired('thisR',vFunc);
p.addRequired('matName',@ischar);

p.parse(thisR, matName, varargin{:});
thisR = p.Results.thisR;
matName = p.Results.matName;

% Assuming varargin are fluorophores - concentration paired.
fluorophores  = varargin(1:2:numel(varargin));
concentration = varargin(2:2:numel(varargin));

%% wave range is hardcoded in PBRT
wave = 365:5:705;

%% Check if the target material exists
if ~isfield(thisR.materials.list, matName)
    error('Unknown material name %s', matName);
end

%% Make sure the number of fluorophores matches number of concentration
if numel(fluorophores) ~= numel(concentration)
    error('Number of fluorophores mush match number of concentrations!');
end

if numel(fluorophores) == 1
    thisFluo = fluorophoreRead(fluorophores{1},'wave',wave);
    % Here is the excitation emission matrix
    eem = fluorophoreGet(thisFluo,'eem');
    
    scalar = concentration{1};
else
    eem = zeros(numel(wave));
    
    for ii = 1:numel(fluorophores)
        thisConcentration = concentration{ii};
        thisFluo = fluorophoreRead(fluorophores{ii}, 'wave', wave);
        thisEEM = fluorophoreGet(thisFluo, 'eem');
        
        eem = eem + thisEEM * thisConcentration * thisConcentration;
    end
    
    % Since it is a mixed fluorophores, each scalar has been combined
    % through the summation process.
    scalar = 1;
end

% The data are converted to a vector like this
flatEEM = eem';
vec = [wave(1) wave(2)-wave(1) wave(end) flatEEM(:)'];
% Assign the eem
thisR.materials.list.(matName).photolumifluorescence = vec;

thisR.materials.list.(matName).floatconcentration = scalar;

end