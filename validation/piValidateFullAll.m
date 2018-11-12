function piValidateFullAll(varargin)
% Full run of iset3d validations. 
%
% Syntax:
%     piValidateFullAll(varargin)

%% Close all figures so that we start with a clean slate
close all;

%% Validation scripts
try
    v_iset3d;
catch
    error('At least one validation script failed');
end

end