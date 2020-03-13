function [ subAdditivityValues ] = calculateSubAdditivity

contrasts = {100, 200, 400};
[ discomfortRatingsStruct ] = loadDiscomfortRatings;

for contrast = 1:length(contrasts)
   
    meanLMSRating = mean([discomfortRatingsStruct.controlDiscomfort.LMS.(['Contrast', num2str(contrasts{contrast})]), discomfortRatingsStruct.mwaDiscomfort.LMS.(['Contrast', num2str(contrasts{contrast})]), discomfortRatingsStruct.mwoaDiscomfort.LMS.(['Contrast', num2str(contrasts{contrast})])]);
    meanMelanopsinRating = mean([discomfortRatingsStruct.controlDiscomfort.Melanopsin.(['Contrast', num2str(contrasts{contrast})]), discomfortRatingsStruct.mwaDiscomfort.Melanopsin.(['Contrast', num2str(contrasts{contrast})]), discomfortRatingsStruct.mwoaDiscomfort.Melanopsin.(['Contrast', num2str(contrasts{contrast})])]);
    meanLightFluxRating = mean([discomfortRatingsStruct.controlDiscomfort.LightFlux.(['Contrast', num2str(contrasts{contrast})]), discomfortRatingsStruct.mwaDiscomfort.LightFlux.(['Contrast', num2str(contrasts{contrast})]), discomfortRatingsStruct.mwoaDiscomfort.LightFlux.(['Contrast', num2str(contrasts{contrast})])]);

    subAdditivityScore = ((meanLMSRating + meanMelanopsinRating) - meanLightFluxRating)/(meanLMSRating + meanMelanopsinRating);
    subAdditivityValues.(['Contrast', num2str(contrasts{contrast})]) = subAdditivityScore;
    
end

end