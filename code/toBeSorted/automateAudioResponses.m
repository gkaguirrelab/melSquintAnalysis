function [ trialStruct ] = automateAudioResponses(subjectID)

cd ~/go/bin
trialRatingVector = [];
for sessionNumber = 1:4
    for acquisitionNumber = 1:10
        for trialNumber = 1:10
            systemCommand = ['./houndify-sdk-go --id ppwuCLwLImeFgQ2dSMqOfw== --key ReHUt7nL1gUh-WnubMM4fRs17v1EpSeEwFa0Aybe2GNZkeZkIM8A6yeGC8y2HkdXSNK_d7ksD9wCgv3Q_rmLyA== --voice ~/Dropbox\ \(Aguirre-Brainard\ Lab\)/MELA_processing/Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectID, '/audioResponses/', subjectID, '_session', num2str(sessionNumber, '%02.f'), '_acquisition', num2str(acquisitionNumber, '%02.f'), '_trial', num2str(trialNumber, '%02.f'), '.wav > ~/trialResult.txt'];
            system(systemCommand);
            
            fileID = fopen('~/trialResult.txt');
            textFileContents = textscan(fileID, '%s');
            trialRatingRaw = textFileContents{1}{end};
            
            if strcmp(trialRatingRaw, '0') || strcmp(trialRatingRaw, 'zero') || strcmp(trialRatingRaw, 'siro')
                trialRating = 0;
            elseif strcmp(trialRatingRaw, '1') || strcmp(trialRatingRaw, 'one') || strcmp(trialRatingRaw, 'won')
                trialRating = 1;
            elseif strcmp(trialRatingRaw, '2') || strcmp(trialRatingRaw, 'two') || strcmp(trialRatingRaw, 'too') ||strcmp(trialRatingRaw, 'to')
                trialRating = 2;
            elseif strcmp(trialRatingRaw, '3') || strcmp(trialRatingRaw, 'three')
                trialRating = 3;
            elseif strcmp(trialRatingRaw, '4') || strcmp(trialRatingRaw, 'four') || strcmp(trialRatingRaw, 'for') || strcmp(trialRatingRaw, 'fore')
                trialRating = 4;
            elseif strcmp(trialRatingRaw, '5') || strcmp(trialRatingRaw, 'five')
                trialRating = 5;
            elseif strcmp(trialRatingRaw, '6') || strcmp(trialRatingRaw, 'six')
                trialRating = 6;
            elseif strcmp(trialRatingRaw, '7') || strcmp(trialRatingRaw, 'seven')
                trialRating = 7;
            elseif strcmp(trialRatingRaw, '8') || strcmp(trialRatingRaw, 'eight') || strcmp(trialRatingRaw, 'ate')
                trialRating = 8;
            elseif strcmp(trialRatingRaw, '9') || strcmp(trialRatingRaw, 'nine')
                trialRating = 9;
            elseif strcmp(trialRatingRaw, '10') || strcmp(trialRatingRaw, 'ten')
                trialRating = 10;
            else
                trialRating = NaN;
            end
            
            trialRating;
            trialRatingVector(end+1) = trialRating;
        end
    end
end

end