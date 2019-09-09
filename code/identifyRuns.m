function runsCellArray = identifyRuns(inputVector)
%{
% here's a test vector with 3 clear runs: 1-3, 5-6, and 9-10.
testVector = [1 2 3 5 6 9 10];
runCellArray = identifyRuns(testVector);

%}

if ~isempty(inputVector)
    inputVector = sort(inputVector);
    differenceVector = diff(inputVector);
    runsCellArray = [];
    runsCellArray{1} = inputVector(1);
    
    runsCounter = 1;
    for ii = 1:length(differenceVector)
        if differenceVector(ii) == 1
            runsCellArray{runsCounter} = [runsCellArray{runsCounter}, inputVector(ii+1)];
        else
            runsCounter = runsCounter + 1;
            runsCellArray{runsCounter} = inputVector(ii+1);
        end
    end
else
    runsCellArray = [];
end
end