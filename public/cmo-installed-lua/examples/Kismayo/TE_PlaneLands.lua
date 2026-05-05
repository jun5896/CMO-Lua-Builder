local theReconTeam = ScenEdit_GetUnit({guid='a818d4d3-2693-4805-b8c8-8692781f97e0'})

local theMessage = "We've spotted the courier. He just got into an SUV is being driven off to the South in a convoy of civilian vehicles. We won't be able to keep up with them. Recommend you maintain visual contact with an unmanned asset, out."

theMessage = GenerateRadioMessageBody(theMessage,theReconTeam.name)

RadioMessage('SATCOM','316.2 MHz Encrypted',theMessage,{latitude='0.405736040691981', longitude='42.6775647389569'})

local theCar = ScenEdit_AddUnit({
    side='Terrorists',
    type='Facility',
    dbid=622,
    name='Courier Convoy',
    latitude='0.405736040691981', 
    longitude='42.6775647389569'
})

local theCourse = {
    { latitude = 0.374251398084924, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6722649913351 },
    { latitude = 0.332762892139172, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6818873066299 }, 
    { latitude = 0.297305531830235, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6674710283163 },
    { latitude = 0.269663188475526, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6794908770386 },
    { latitude = 0.23662028675741, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6590658672847 },
    { latitude = 0.223405047789074, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6224137351105 },
    { latitude = 0.195768201142512, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6091956049429 }, 
    { latitude = 0.171135869380388, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6260186559421 },
    { latitude = 0.139292219926243, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6296229106117 },
    { latitude = 0.120058732626539, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.6061785969338 },
    { latitude = 0.114031668856905, TypeOf = 'ManualPlottedCourseWaypoint', longitude = 42.5538728358378 },
}

ScenEdit_SetUnit({guid=theCar.guid,course=theCourse})

ScenEdit_DeleteUnit({guid=theReconTeam.guid})