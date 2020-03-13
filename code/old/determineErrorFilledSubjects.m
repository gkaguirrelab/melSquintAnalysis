function determineErrorFilledSubjects(errorFrameThreshold)

[subjectIDs, subjectListStruct] = generateSubjectList('method', 'sufficientSubjects');


for ss = 1:length(fieldnames(subjectListStruct))
    for session = 1:length(subjectListStruct.(subjectIDs{ss}))
        % check that fitParams exist for that session
        firstAcqFitParamsFileName = fullfile(getpref('melSquintAnalysis', 'melaProcessingPath'), 'Experiments', 'OLApproach_Squint', 'SquintToPulse', 'DataFiles', subjectIDs{ss}, subjectListStruct.(subjectIDs{ss}){session}, 'videoFiles_acquisition_01', 'fitParams.mat');
        
        if exist(firstAcqFitParamsFileName)
            load(firstAcqFitParamsFileName);
            
            if isfield(fitParams, 'candidateThetas')
                if isequal(fitParams.candidateThetas, 0:pi/16:2*pi)
                    fprintf('%s, %s\n', subjectIDs{ss}, subjectListStruct.(subjectIDs{ss}){session});
                    
                    % assess the damage
                    
                    for aa = 1:6
                        for tt = 2:10
                            
                            try
                            errorIndices = [];
                            controlFileContents = [];
                            controlFileName = fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, subjectListStruct.(subjectIDs{ss}){session}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_controlFile.csv', tt));
                            controlFileID = fopen(controlFileName);
                            controlFileContents = textscan(controlFileID,'%s', 'Delimiter',',');
                            errorIndices = strfind(controlFileContents{1}, 'error');
                            errorIndices = find([errorIndices{:}]);
                            numberOfErrorFrames = length(errorIndices);
                            fclose(controlFileID);
                            
                            if numberOfErrorFrames/1050 > errorFrameThreshold
                                
                                finalFitVideoName = fullfile(getpref('melSquintAnalysis','melaProcessingPath'), 'Experiments/OLApproach_Squint/SquintToPulse/DataFiles/', subjectIDs{ss}, subjectListStruct.(subjectIDs{ss}){session}, sprintf('videoFiles_acquisition_%02d', aa), sprintf('trial_%03d_finalFit.avi', tt));
                                if exist(finalFitVideoName)
                                    
                                    commandString = sprintf('applySceneGeometryPerSession(''%s'', ''%s'', ''videoRange'', {[%d, %d], [%d, %d]}', subjectIDs{ss}, subjectListStruct.(subjectIDs{ss}){session}, aa, tt, aa, tt);
                                    system(['echo "', commandString, '" >> ', '~/Documents/MATLAB/projects/melSquintAnalysis/code/', ['errorFilledVideos_', num2str(errorFrameThreshold), '.m']]);
                                end
                                
                            end
                            
                            catch
                                fprintf('I messed up on %s, %s, %d, %d', subjectIDs{ss}, subjectListStruct.(subjectIDs{ss}){session}, aa, tt); 
                                
                            end
                        end
                    end
                end
            end
            
            
            
        end
        
        
        
        
        
    end
    % if
    
    
    
    
end

end


% will then need to determine if all of those will need processing...