function [ significance ] = evaluateSignificanceOfMedianDifference(sampleOne, sampleTwo, dropboxAnalysisDir, varargin)

% the variable significance reflects the probability of observing the
% actual median difference or greater, in units of %
%% Parse input
p = inputParser; p.KeepUnmatched = true;
p.addParameter('makePlot',false,@islogical);
p.addParameter('sidedness',1,@isnumeric);
p.addParameter('nSimulations',100000,@isnumeric);
p.addParameter('outDir','permutationTesting',@isnchar);

p.parse(varargin{:});



nSimulations = p.Results.nSimulations;


%% run the permutation testing
result = [];

if ~isrow(sampleOne)
    sampleOne = sampleOne';
end
if ~isrow(sampleTwo)
    sampleTwo = sampleTwo';
end
combinedSample = [sampleOne; sampleTwo];


for nn = 1:nSimulations
        for ss = 1:length(sampleOne)
            shouldWeFlipLabel = round(rand);
    
            if shouldWeFlipLabel == 1 % then flip the label for that subject
                firstGroup(ss) = sampleOne(ss);
                secondGroup(ss) = sampleTwo(ss);
            elseif shouldWeFlipLabel == 0
                secondGroup(ss) = sampleOne(ss);
                firstGroup(ss) = sampleTwo(ss);
            end
        end
    
    % randomly flip labels
%     A=cell2mat(arrayfun(@(x) randperm(2,2),(1:length(sampleOne))','un',0));
%     
%     % apply label flipping to the data
%     flippedData = combinedSample(A');
    
    
    
    
        %result = [result, median(flippedData(1,:)) - median(flippedData(2,:))];

    result = [result, median(firstGroup) - median(secondGroup)];
end

if p.Results.sidedness == 1
observedMedianDifference = median(sampleOne) - median(sampleTwo);

numberOfPermutationsLessThanObserved = result < observedMedianDifference;
numberOfPermutationsGreaterThanObserved = (result) >= observedMedianDifference;

elseif p.Results.sidedness == 2
    
    observedMedianDifference = abs(median(sampleOne) - median(sampleTwo));
    numberOfPermutationsLessThanObserved = abs(result) < observedMedianDifference;
    numberOfPermutationsGreaterThanObserved = abs(result) >= observedMedianDifference;

end

%significance = 1-(sum(numberOfPermutationsLessThanObserved)/length(result)); % in units of %
significance = (sum(numberOfPermutationsGreaterThanObserved)/length(result));

%% plot the results if specified
if p.Results.makePlot
    
    
    plotFig = figure;
    hold on
    histogram(result);
    ylims=get(gca,'ylim');
    xlims=get(gca,'xlim');
    line([observedMedianDifference, observedMedianDifference], [ylims(1), ylims(2)], 'Color', 'r')
    
    string = (sprintf(['Observed Median Difference = ', num2str(observedMedianDifference), '\n', num2str(sum(numberOfPermutationsLessThanObserved)/length(result)*100), '%% of simulations < Observed Median Difference']));
    
    ypos = 0.9*ylims(2);
    xpos = xlims(1)-0.1*xlims(1);
    text(xpos, ypos, string)
    
end

end % end function