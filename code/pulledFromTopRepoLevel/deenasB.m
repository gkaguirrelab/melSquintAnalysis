% applySceneGeometryPerSession('MELA_0213',1, 'resume', true);
% 
% applySceneGeometryPerSession('MELA_0213',2, 'resume', true);
% 
% 
% applySceneGeometryPerSession('MELA_0201',2,'resume', true);
% applySceneGeometryPerSession('MELA_0201',4,'resume', true);
% 
% 
% applySceneGeometryPerSession('MELA_0130', 1, 'resume', true, 'forceApplySceneGeometryOnly', true)
% 
% applySceneGeometryPerSession('MELA_0160', 2, 'resume', true)
% 
% applySceneGeometryPerSession('MELA_0170', 3, 'resume', true);
% applySceneGeometryPerSession('MELA_0170', 4, 'resume', true);
% 
% applySceneGeometryPerSession('MELA_0138', 4, 'resume', true)
% 
% trackSubject('MELA_0223', 1, 'resume', true);
% trackSubject('MELA_0223', 2, 'resume', true);
% trackSubject('MELA_0222', 3, 'resume', true);
% trackSubject('MELA_0222', 4, 'resume', true);
% 
% applySceneGeometryPerSession('MELA_0167', 1, 'resume', true)
% applySceneGeometryPerSession('MELA_0167', 2, 'resume', true)
% applySceneGeometryPerSession('MELA_0167', 3, 'resume', true)
% applySceneGeometryPerSession('MELA_0167', 4, 'resume', true)
% 
% %applySceneGeometryPerSession('MELA_0221', 3, 'resume', false, 'reprocessEverything', true)
% 
% 
% applySceneGeometryPerSession('MELA_0181', 3, 'resume', true)
% %applySceneGeometryPerSession('MELA_0147', 2, 'resume', true, 'reprocessEverything', true)
subjectID = 'MELA_3009';
experiment = 1;
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){1}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){2}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
experiment = 2;
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){1}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){2}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])

subjectID = 'MELA_3036';
experiment = 1;
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){1}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){2}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
