function bool = piScitranExists
% Check the scitran installation. Current required version is 432+
%
% Syntax:
%   bool = piScitranExists
%
% Description:
%    Check the scitran installation. The current requirement is to have
%    version 432 or higher installed.
%
%    Note: This does not check that the user has the stanfordlabs account.
%
% Inputs:
%    None.
%
% Outputs:
%    bool - Boolean. True/False indicating if a supported version of
%           scitran is installed.
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/XX  ZL/BW  SCIEN Created
%    03/25/19  JNM    Documentation pass. update version from 410 to 432.

if isempty(which('scitran'))
    error('You must have scitran with a stanfordlabs Flywheel account');
elseif stFlywheelSDK('installed version') < 432
    error('You must have version 4.3.2 or higher installed');
else
    bool = true;
end

end
