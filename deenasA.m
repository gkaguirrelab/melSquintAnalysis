% applySceneGeometryPerSession('MELA_0147',2,'resume', true);
% applySceneGeometryPerSession('MELA_0147',3,'resume', true);
% 
% 
% applySceneGeometryPerSession('MELA_0124',3,'resume', true, 'forceApplySceneGeometryOnly', true);
% 
% applySceneGeometryPerSession('MELA_0126',2,'resume', true);
% 
% applySceneGeometryPerSession('MELA_0128',2,'resume', true);
% applySceneGeometryPerSession('MELA_0160', 1, 'resume', true)
% 
% applySceneGeometryPerSession('MELA_0140', 2, 'resume', true)
% 
% applySceneGeometryPerSession('MELA_0152', 1, 'resume', true)
% applySceneGeometryPerSession('MELA_0152', 2, 'resume', true)
% applySceneGeometryPerSession('MELA_0152', 3, 'resume', true)
% applySceneGeometryPerSession('MELA_0152', 4, 'resume', true)
% 
% %applySceneGeometryPerSession('MELA_0147', 1, 'resume', true, 'reprocessEverything', true)
% applySceneGeometryPerSession('MELA_0168', 2, 'resume', true)
% applySceneGeometryPerSession('MELA_0168', 3, 'resume', true)
% applySceneGeometryPerSession('MELA_0168', 4, 'resume', true)
% 
% applySceneGeometryPerSession('MELA_0181', 2, 'resume', true)


subjectID = 'MELA_3032';
experiment = 1;
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){1}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){2}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){3}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
experiment = 2;
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){1}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){2}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])
applySceneGeometryPerSession(subjectID, subjectStruct.(['experiment', num2str(experiment)]).(subjectID){3}, 'Protocol', 'Deuteranopes', 'experimentNumber',['experiment_', num2str(experiment)])


