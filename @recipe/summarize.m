function summarize(thisR,str)
% Summarize the recipe entries
%
% Syntax
%   recipe.summarize(str)
%
% Description
%   Prints to the console a summary of the recipe parameters.  The string
%   suggests which parameters to emphasize.
%
% Inputs
%   str:  Emphasis on 'all','camera','film',lookat','assets','metadata'
%
% Key/value pairs
%   N/A
%
% Outputs:
%   N/A
%
% A utility to improve the quality of programming life by printing to the
% console a quick and clear look at the critical rendering recipe
% parameters.
%
% Wandell
%
% See also
%  recipe
%

%% Parse

warning('Not much implemented yet');

str = ieParamFormat(str);

validStr = {'all','camera','film','lookat','assets','metadata'};
p = inputParser;
p.addRequired('thisR',@(x)(isequal(class(x),'recipe')));
p.addRequired('str',@(x)(ismember(x,validStr)));
p.parse(thisR,str);

%% Start to flesh out descriptions

switch str
    case 'all'
    case 'camera'
        fprintf('\nCamera parameters\n-----------\n');
        fprintf('Sub type: %s\n',thisR.camera.subtype);
        fprintf('Lens file name:   %s\n',thisR.get('lens file'));
        fprintf('Aperture diameter (mm): %0.2f\n',thisR.get('aperture diameter'));
        fprintf('Focal distance (m):   %0.2f\n',thisR.get('focal distance'));
        fprintf('Exposure time (s): %f\n',thisR.get('exposure time'));
        fprintf('\n\n');
    case 'film'
    case 'lookat'
    case 'assets'
    case 'metadata'
    otherwise
        error('Unknown parameter %s\n',str);
end

end