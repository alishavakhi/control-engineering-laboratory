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
 
 %Mechanicalloadnominalparameters
 
 % inertiadiscparams
 mld.JD=3e-5; % loaddiscinertia
 mld.BD=0.0; % loadviscouscoeff(n.a.)
 
 % overallmechloadparams
 mld.J =mld.JD+gbox.J; % totalinertia
 mld.B =2.5e-4; % totalviscousfriccoeff(estimated)
 mld.tausf=1.0e-2; % totalstaticfriction(estimated)
 
 %%Voltagedrivernominalparameters
 
 % op−ampcircuitparams
 drv.R1=7.5e3; % op−ampinputresistor(dactonon−invertingin)
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
 
 %%Dataacquisitionboard(daq)data
 
 % NI PCI−6221 DAC data
 daq.dac.bits = 16;
 daq.dac.fs = 10;
 % resolution (bits)
 % full scale
 daq.dac.q = 2*daq.dac.fs/(2^daq.dac.bits-1);
 % quantization
 
 % NI PCI−6221 ADC data
 daq.adc.bits = 16;
 % resolution (bits)
 daq.adc.fs = 10;
 % full scale (as set in SLDRT Analog Input block)
 daq.adc.q = 2*daq.adc.fs/(2^daq.adc.bits-1);
 % quantization

%Simplified Model
Beq = 7.9953e-07;
Jeq =5.6441e-07; 
Tau_sf = 0.0080;
Req = sens.curr.Rs+mot.R;
Km_calc = (drv.dcgain*mot.Kt)/(Req*Beq +mot.Kt*mot.Ke);
Tm_calc = (Req*Jeq)/(Req*Beq +mot.Kt*mot.Ke);

simplified_P = tf(Km_calc, [Tm_calc*gbox.N gbox.N 0]);

%Specification
ts = 0.14;
Mp = 0.1;

dt = log(1/Mp)/(sqrt(pi^2 + log(1/Mp)^2));
wn = 3/(dt*ts);
phim = atan(2*dt/sqrt(sqrt(1+4*dt^4) - 2*dt^2));
TL = 1/(3*wn);



%PID parameters with Bode

delta_K = 1/abs(evalfr(simplified_P, 1j*wn));
delta_phi = -3.14 + phim - angle(evalfr(simplified_P, 1j*wn));
alpha = 4.7;

Kp = delta_K*cos(delta_phi)
Td = (tan(delta_phi) + sqrt ((tan(delta_phi))^2 + 4/alpha))/(2*wn);
Kd = Kp*Td
Ti = alpha*Td;
Ki = Kp/Ti

%Anti_windup
Kw_theory = 5 /ts;

%Experimentally attained
Kw = 40;

%High-pass Filter (Real-Derivative)

wc = 2*pi*50;
wc2 = wc*wc;
delta_i = 1/sqrt(2);


%State-space realization
A = [0, 1;
     0, -1/Tm_calc;];

B = [0, Km_calc/(gbox.N*Tm_calc)].';
C = [1, 0];
D = 0;

Inertia_comp = gbox.N * Req * Jeq / mot.Kt /drv.dcgain;
N2Beq = (gbox.N^2) * Beq ;
Fric_comp = Req / mot.Kt / drv.dcgain/gbox.N;
BEMF_comp = gbox.N * mot.Ke /drv.dcgain;
