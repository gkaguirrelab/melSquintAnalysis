% applySceneGeometryPerSession('MELA_0223',3, 'resume', true);
% applySceneGeometryPerSession('MELA_0223',4, 'resume', true);
% 
% 
% applySceneGeometryPerSession('MELA_0121', 2, 'resume', true);
% applySceneGeometryPerSession('MELA_0121', 3, 'resume', true);
% 
% 
% applySceneGeometryPerSession('MELA_0131', 2, 'resume', true);
% 
% applySceneGeometryPerSession('MELA_0170', 1, 'resume', true);
% applySceneGeometryPerSession('MELA_0170', 2, 'resume', true);
% 
% 
% applySceneGeometryPerSession('MELA_0138', 3, 'resume', true)
% 
% applySceneGeometryPerSession('MELA_0140', 1, 'resume', true)
% 
% %applySceneGeometryPerSession('MELA_0221', 3, 'resume', false, 'reprocessEverything', true)
% 
% trackSubject('MELA_0218', 2, 'resume', true);
% applySceneGeometryPerSession('MELA_0187', 4, 'resume', true)
% applySceneGeometryPerSession('MELA_0181', 4, 'resume', true)
% 
% applySceneGeometryPerSession('MELA_0219', 1, 'resume', true)
% applySceneGeometryPerSession('MELA_0169', 1, 'resume', true)
% applySceneGeometryPerSession('MELA_0169', 2, 'resume', true)
% applySceneGeometryPerSession('MELA_0169', 3, 'resume', true)
% applySceneGeometryPerSession('MELA_0169', 4, 'resume', true)
subjectID = 'MELA_3035';
experiment = 1;
%applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){1}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
%applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){2}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){3}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
