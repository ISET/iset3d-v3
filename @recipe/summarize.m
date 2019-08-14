function [out, namelist] = summarize(thisR,str)
% Summarize the recipe 
%
% Syntax
%   [out, namelist] = recipe.summarize(str)
%
% Description
%   Prints a summary of the recipe parameters to the console. 
%
% Inputs
%   str:  'all','file','render','camera','film',lookat','assets',
%         'materials',or 'metadata' 
%
% Key/value pairs
%   N/A
%
% Outputs:
%   out  - Either the object described our empty
%   namelist - If str = 'assets', a sorted list of the names of the assets,
%              or if str = 'materials' the names of the materials
%
% Description
%    A quick summary of the critical rendering recipe parameters. In
%    several cases the object described is returned
%
% Wandell
%
% See also
%  recipe, recipeGet
%

% Examples:
%{
 c = thisR.summarize('camera');
%}
%{
 [assets, sortedNames] = thisR.summarize('assets');
  sortedNames
%}
%{
 [~,sortedNames] = thisR.summarize('all');
%}
%% Parse

validStr = {'all','file','render','camera','film','lookat','assets','materials','metadata'};
p = inputParser;
p.addRequired('thisR',@(x)(isequal(class(x),'recipe')));
p.addRequired('str',@(x)(ismember(x,validStr)));

% Default for str is 'all'.  Force to lower case.
if ~exist('str','var'),str = 'all'; end
str = ieParamFormat(str);

p.parse(thisR,str);

namelist = [];
out = [];
%% Build descriptions

switch str
    case 'all'
        thisR.summarize('file');
        thisR.summarize('render');
        thisR.summarize('camera');
        thisR.summarize('film');
        thisR.summarize('lookat');
        [~,namelist] = thisR.summarize('assets');
        thisR.summarize('materials');
        thisR.summarize('metadata');
    case 'file'
        fprintf('\nFile information\n-----------\n');
        fprintf('Input:  %s\n',thisR.get('input file'));
        fprintf('Output: %s\n',thisR.get('output file'));
        if isfield(thisR,'exporter'), fprintf('Exported by %s\n',thisR.exporter); end
        fprintf('\n');
        
    case 'render'
        fprintf('\nRenderer information\n-----------\n');
        if isempty(thisR.renderer), return; end
        out = thisR.renderer;
        fprintf('Sampler\n');
        fprintf('Integration\n');
        fprintf('renderer\n');
        fprintf('filter\n');
        namelist = thisR.world;  % Abusive.  Change variable name.
        fprintf('\n');
        
    case 'camera'
        fprintf('\nCamera parameters\n-----------\n');
        if isempty(thisR.camera), return; end
        out = thisR.camera;
        
        fprintf('Sub type: %s\n',thisR.camera.subtype);
        fprintf('Lens file name:   %s\n',thisR.get('lens file'));
        fprintf('Aperture diameter (mm): %0.2f\n',thisR.get('aperture diameter'));
        fprintf('Focal distance (m):\t%0.2f\n',thisR.get('focal distance'));
        fprintf('Exposure time (s):\t%f\n',thisR.get('exposure time'));
        fprintf('Field of view (deg):\t%f\n',thisR.get('fov'));
        fprintf('\n');
        
    case 'film'
        out = thisR.film;
        fprintf('\nFilm parameters\n-----------\n');
        fprintf('subtype: %s\n',out.subtype);
        fprintf('x,y resolution: %d %d (samples)\n',thisR.get('film resolution'));
        fprintf('diagonal:   %d (mm)\n',thisR.get('film diagonal'));
        fprintf('\n');
        
    case 'lookat'
        fprintf('\nLookat parameters\n-----------\n');
        if isempty(thisR.lookAt), return; end
        out = thisR.lookAt;
        fprintf('from:\t%.3f %.3f %.3f\n',thisR.get('from'));
        fprintf('to:\t%.3f %.3f %.3f\n',thisR.get('to'));
        fprintf('up:\t%.3f %.3f %.3f\n',thisR.get('up'));
        fprintf('object distance: %.3f (m)',thisR.get('object distance'));
        fprintf('\n');
        
    case 'assets'
        fprintf('\nAssets\n-----------\n');
        if isempty(thisR.assets), return; end
        out = thisR.assets;
        nAssets = numel(out);
        fprintf('Number:  %d\n',nAssets);
        nMoving = 0;
        for ii=1:nAssets
            if isfield(out, 'motion')
                if ~isempty(out(ii).motion)
                    nMoving = nMoving + 1;
                end
            end
        end
        fprintf('Moving  assets: %d\n',nMoving);
        fprintf('Static  assets: %d\n',nAssets - nMoving);
        namelist = cell(nAssets,1);
        for ii=1:nAssets
            namelist{ii} = thisR.assets(ii).name;
        end
        namelist = sort(unique(namelist));
        fprintf('\n');
        
    case 'materials'
        fprintf('\nMaterials\n-----------\n');
        if isempty(thisR.materials), return; end
        out = thisR.materials;
        namelist = sort(unique(fieldnames(thisR.materials.list)));
        fprintf('Number:\t%d\n',numel(namelist));
        [~,filename,ext] = fileparts(thisR.materials.inputFile_materials);
        fprintf('File:\t%s\n',[filename,ext])
        fprintf('\n');
        
    case 'metadata'

        fprintf('\nMetadata\n-----------\n');
        if isempty(thisR.metadata), return; end
        out = thisR.metadata;

        namelist = fieldnames(thisR.metadata);
        fprintf('Fields:\n');
        for ii=1:numel(namelist)
            fprintf('%d\t%s\n',ii,namelist{ii});
        end
        fprintf('\n');
        
    otherwise
        error('Unknown parameter %s\n',str);
end

end