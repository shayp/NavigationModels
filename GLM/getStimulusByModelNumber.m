function stimulus = getStimulusByModelNumber(modelNumber, posgrid, hdgrid, velgrid, bordergrid)

switch modelNumber
    case 1
        stimulus = [posgrid hdgrid velgrid bordergrid];
    case 2
        stimulus = [posgrid hdgrid velgrid];
    case 3
        stimulus = [posgrid hdgrid bordergrid];
    case 4
        stimulus = [posgrid velgrid bordergrid];
    case 5
        stimulus = [hdgrid velgrid bordergrid];
    case 6
        stimulus = [posgrid hdgrid];
    case 7
        stimulus = [posgrid velgrid];
    case 8
        stimulus = [posgrid bordergrid];
    case 9
        stimulus = [hdgrid velgrid];
    case 10
        stimulus = [hdgrid bordergrid];
    case 11
        stimulus = [velgrid bordergrid];
    case 12
        stimulus = [posgrid];
    case 13
        stimulus = [hdgrid];
    case 14
        stimulus = [velgrid];
    case 15
        stimulus = [bordergrid];


end