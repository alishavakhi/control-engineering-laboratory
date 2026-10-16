load('Estimated_Params.mat');
%%Generalparametersandconversiongains
% conversiongains
rpm2rads=2*pi/60; % [rpm] −>[rad/s]
rads2rpm=60/2/pi; % [rad/s]−>[rpm]
rpm2degs=360/60; % [rpm] −>[deg/s]
degs2rpm=60/360; % [deg/s]−>[rpm]
deg2rad=pi/180; % [deg] −>[rad]
rad2deg=180/pi; % [rad] −>[deg]
ozin2Nm=0.706e-2; % [oz*inch]−>[N*m]

%%DCmotornominalparameters

% brushedDC−motorFaulhaber2338S006S
mot.R =2.6; % armatureresistance
mot.L =180e-6; % armatureinductance
mot.Kt =1.088 * ozin2Nm; % torqueconstant
mot.Ke =0.804e-3* rads2rpm; % back−EMFconstant
mot.J =5.523e-5* ozin2Nm; % rotorinertia
mot.B =0.0; % viscousfrictioncoeff(n.a.)
mot.eta =0.69; % motorefficiency
mot.PN =3.23/mot.eta; % nominaloutputpower
mot.UN =6; % nominalvoltage
mot.IN =mot.PN/mot.UN; % nominalcurrent
mot.tauN=mot.Kt*mot.IN; % nominaltorque
mot.taus=2.42 * ozin2Nm; % stalltorque
mot.w0 =7200 * rpm2rads; % no−loadspeed

%%Gearboxnominalparameters

% planetarygearboxMicromotorSA23/1
gbox.N1 =14; % 1streductionratio(planetarygearbox)
gbox.eta1=0.80; % gearboxefficiency

% externaltransmissiongears
gbox.N2 =1; % 2ndreductionratio(externaltrasmissiongears)
gbox.J72 =1.4e-6; % inertiaofasingleexternal72toothgear
gbox.eta2=1; % externaltrasmissionefficiency(n.a.)

% overallgearboxdata
gbox.N =gbox.N1*gbox.N2; % totalreductionratio
gbox.eta=gbox.eta1*gbox.eta2; % totalefficiency
gbox.J =3*gbox.J72; % totalinertia(atgearboxoutput)

%%Mechanicalload(mld)nominalparameters

% hubparams
mld.Jh=  6.84e-04; % momentofinertia
mld.Bh=  2.5e-4; % viscousfrictioncoeff
mld.tausf= 0.0080; % staticfriction(estimated)

% beam&elasticjointparams
mld.Jb=1.4e-3; % momentofinertia
mld.d =5.0e-2; % flexjointdampingcoeff(estimated)
mld.wn=24.5; % flexjointnaturalfreq(estimated)
mld.Bb=Bb_hat; % beamviscousfriction
mld.k =k_hat; % flexjointstiffness


%%Voltagedrivernominalparameters

% op−ampcircuitparams
drv.R1 = 7.5e3;
drv.R2=1.6e3; % op−ampinputresistor(non−invertingintognd)
drv.R3=1.2e3; % op−ampfeedbackresistor(outputto invertingin)
drv.R4=0.5e3; % op−ampfeedbackresistor(invertingintognd)
drv.C1=100e-9; % op−ampinputcapacitor
drv.outmax=12; % op−ampmaxoutputvoltage

% voltagedriverdc−gain
drv.dcgain=drv.R2/(drv.R1+drv.R2) * (1+drv.R3/drv.R4);

% voltagedrivertimeconstant
drv.Tc=drv.C1 * drv.R1*drv.R2/(drv.R1+drv.R2);

%%Sensorsdata

% shuntresistor
sens.curr.Rs=0.5;

% Hewlett−PackardHEDS−5540#A06opticalencoder
sens.enc.ppr=500*4; % pulsesperrotation
sens.enc.pulse2deg=360/sens.enc.ppr; % [pulses]−>[deg]
sens.enc.pulse2rad=2*pi/sens.enc.ppr; % [pulses]−>[rad]
sens.enc.deg2pulse=sens.enc.ppr/360; % [deg]−>[pulses]
sens.enc.rad2pulse=sens.enc.ppr/2/pi; % [rad]−>[pulses]

% potentiometer1(Spectrol138−0−0−103)−installedonmotorbox
sens.pot1.range.R =10e3; % ohmicvaluerange
sens.pot1.range.V =5; % voltagerange
sens.pot1.range.th_deg=345; % anglerange[deg]
sens.pot1.range.th =sens.pot1.range.th_deg * deg2rad; % anglerange[rad]
sens.pot1.deg2V =sens.pot1.range.V/sens.pot1.range.th_deg; % sensitivity[V/deg]
sens.pot1.rad2V =sens.pot1.range.V/sens.pot1.range.th; % sensitivity[V/rad]
sens.pot1.V2deg =1/sens.pot1.deg2V; % conversiongain[V]−>[deg]
sens.pot1.V2rad =1/sens.pot1.rad2V; % conversiongain[V]−>[rad]

% potentiometer2(Spectrol357−0−0−103)−installedonhub
sens.pot2.range.R =10e3; % ohmicvaluerange
sens.pot2.range.V =5; % voltagerange
sens.pot2.range.th_deg=345; % anglerange[deg]
sens.pot2.range.th =sens.pot2.range.th_deg * deg2rad; % anglerange[rad]
sens.pot2.deg2V =sens.pot2.range.V/sens.pot2.range.th_deg; % sensitivity[V/deg]
sens.pot2.rad2V =sens.pot2.range.V/sens.pot2.range.th; % sensitivity[V/rad]
sens.pot2.V2deg =1/sens.pot2.deg2V; % conversiongain[V]−>[deg]
sens.pot2.V2rad =1/sens.pot2.rad2V; % conversiongain[V]−>[rad]
sens.pot2.noise.var =3.5e-7; % outnoisevariance[V^2]

%%Dataacquisitionboard(daq)data

% NIPCI−6221DACdata
daq.dac.bits=16; % resolution(bits)
daq.dac.fs =10; % fullscale
daq.dac.q =2*daq.dac.fs/(2^daq.dac.bits-1); % quantization

% NIPCI−6221ADCdata
daq.adc.bits=16; % resolution(bits)
daq.adc.fs =10; % fullscale(assetinSLDRTAnalogInputblock)
daq.adc.q =2*daq.adc.fs/(2^daq.adc.bits-1); % quantization

% total system params
Jeq = mot.J + mld.Jh/(gbox.N^2);
Beq =   7.9953e-07; % estimated in the lab0
Req = sens.curr.Rs + mot.R;

% High-Pass filter params
wc = 2*pi*50;
wc2 = wc*wc;
delta_n = 1/sqrt(2);