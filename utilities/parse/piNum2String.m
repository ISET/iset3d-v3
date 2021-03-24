function string = piNum2String(num)
string='';

persistent perf;
if isempty(perf)
    perf = getpref('ISET','fast_num2string', false);
end

if perf
    if isinteger(num)
        string = int2str(num);
    else
        %formatSpec = '%.5f ';
        formatSpec = 6;
        string = num2str(num, formatSpec);
    end
else
    %I Don't think we need our own for loop?!
    for ii = 1:numel(num)
        if isinteger(num)
            string = [string, ' ' ,int2str(num(ii))]; % look for better perf. -- djc
        else
            formatSpec = '%.5f';
            string = [string, ' ' ,num2str(num(ii), formatSpec)];
        end
    end
end
end