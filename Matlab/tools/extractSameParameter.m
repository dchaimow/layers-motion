function p = extractSameParameter(c,indexHandle)
% c is cell array
% indexHandle is function that returns parameter from cells
parameterCell = cellfun(indexHandle,c,'UniformOutput',false);
for z=2:length(parameterCell)
    if ~isequal(parameterCell{1},parameterCell{z})
        error('parameters differ');
    end
end
p = parameterCell{1};
end