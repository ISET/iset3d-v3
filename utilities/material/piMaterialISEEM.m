function val = piMaterialISEEM(param, varargin)
%%
% Synopsis:
%   val = piMaterialISEEM(param, varargin)
%
% Brief description:
%   Check if a vector is excitation emission matrix.
%   
% Inputs:
%   param   - vector 
%
% Returns:
%   val     - boolean value.

%% parse input
p = inputParser;
p.addRequired('param', @isvector);
p.parse(param, varargin{:});

%%
if numel(param) > 3
    nEntry = ((param(3) - param(1))/param(2) + 1)^2;
    if any(param(4:end) > 1) || ~isequal(nEntry, numel(param(4:end)))
        % If any value is larger than 1, return false
        val = false;
    else
        val = true;
    end
else
    % If the length is no larger than 3, return false
    val = false;
end


end