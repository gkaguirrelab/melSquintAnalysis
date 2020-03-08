function sphericalAmetropia = getSphericalAmetropia(subjectID)

sphericalAmetropiaSpreadsheetFileName = fullfile('~/Downloads/sphericalRefractiveError.xlsx');

try
[num, txt, raw] = xlsread(sphericalAmetropiaSpreadsheetFileName);

index = strfind(txt, subjectID);

rowNumber = find(~cellfun(@isempty,index));

sphericalAmetropiaCell = txt{rowNumber,2};

splitCell = strsplit(sphericalAmetropiaCell, '(');
sphericalAmetropia = str2num(splitCell{1});

catch
    sphericalAmetropia = [];
    
end

end