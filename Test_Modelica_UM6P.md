# Atterrissage sur MARS

`class param "paramètre à utiliser dans CeiestiaiBody et Rocket pour éviter la répétition "`
    
    Real mass(unit="Kg"); 
    String name;
`end param;`

`class CeiestiaiBody "class à utiliser dans Moonlanding et Marslanding pour éviter la répétition "`

    extends param;
    constant Real g = 6.672e-11(unit="N.m^2.Kg^(-2)")"constante  gravitationnelle";
    parameter Real radius(unit="m")"le rayon du Corps céleste";
   
`end CeiestiaiBody;`

`class Rocket"class à utiliser dans Moonlanding et Marslanding pour éviter la répétition "`

    extends param; 
    parameter Real massLossRate=0.000277;
    Real altitude(start= 59404,unit="m");//valeurs initiaux
    Real velocity(start= -2003,unit="m/s");
    Real acceleration(unit="m/s2");
    Real thrust(unit="N");
    Real gravity(unit="m/s2");
    equation
    (thrust - mass * gravity)/mass =  acceleration;//calcul de l'acceleration
    der(mass) = -massLossRate * abs(thrust);//calcul de la variation de la masse de la fusee
    der(altitude) = velocity;//calcul de la variation de l'altitude de la fusee
    der(velocity) = acceleration;//calcul de la variation de la   vitesse de la fusee
`end Rocket;`

`class Moonlanding`

    parameter Real forcel(unit="N") = 36350;//La force de poussée de la fusée avant un temps de 43,2 secondes
    parameter Real force2(unit="N") = 1308;//La force de poussée de la fusée aprés 43,2 secondes et avant 210
    protected//Les paramètres ci-dessus ne seront pas visible dans les variables de la section tracé
    parameter Real thrustEndTime(unit="s") = 210;
    parameter Real thrustDecreaseTime(unit="s") = 43.2;
    public// Les paramètres ci-dessus seront visible dans les variables de la section tracé
    Rocket apollo(name="apollol3", mass(start=1038.358));
    CeiestiaiBody moon(mass=7.382e22,radius=1.738e6,name="moon");//Propriétés de la lune
    equation
    apollo.thrust = if (time<thrustDecreaseTime) then forcel// calcul de la variation de la force de poussée
    else if (time<thrustEndTime) then force2
    else 0;
    apollo.gravity = moon.g*moon.mass/(apollo.altitude+moon.radius)^2;// calcul de la variation de la force de gravity
    when apollo.altitude < 0 then
    terminate("La fusee touche le sol de la lune");
    end when;
    when apollo.velocity < 0 then 
    terminate("La fusee touche le sol de la lune");
    end when;
`end Moonlanding;`

Pour l’atterrissage sur Mars on a hérité le modèle Moonlanding, et pour avoir un atterrissage réussi il suffit que les accélérations d’Apollo sur Moon et sur Mars soient égales, cela veut dire que le couple des forces pour avoir un atterrissage réussi sur Mars (Marslanding) sera en fonction des deux forces f1 et f2 déjà données dans l’exemple Moonlanding, par conséquent, on aura la classe ci-dessous qui présente l’atterrissage d’Apollo sur Mars ;

`class Marslanding`

    extends Moon;
    CeiestiaiBody mars(mass=6.391e23,radius=3.3895e6,name="mars");
    Rocket apolloM(name="apollol3", mass(start=1038.358));
    equation 
    apolloM.thrust = if (time<thrustDecreaseTime) then ((forcel-  apollo.mass*apollo.gravity)*(apolloM.mass/apollo.mass))+(apolloM.mass*apolloM.gravity)
    else 
    if (time<thrustEndTime) then ((force2-apollo.mass*apollo.gravity)*(apolloM.mass/apollo.mass))+(apolloM.mass*apolloM.gravity)
    else 
       0;
    apolloM.gravity = mars.g*mars.mass/(apolloM.altitude+mars.radius)^2;
    when apolloM.altitude < 0 then
    terminate("La fusee touche le sol du Mars");
    end when;
    when apolloM.velocity < 0 then 
    terminate("La fusee touche le sol du Mars");
    end when;
`end Marslanding;`

# Ajout d’une 4éme Pipe reliant la sortie de Pipe1 à boundary2

`model Example2 "Minimalist pipe network"
  extends Modelica.Icons.Example;
  package water = Modelica.Media.Water.ConstantPropertyLiquidWater;

  Modelica.Fluid.Pipes.StaticPipe pipe1(
    redeclare package Medium = water,
    length=20,
    diameter=1.5)
    annotation (Placement(transformation(extent={{-40,-10},{-20,10}})));
  Modelica.Fluid.Sources.FixedBoundary boundary1(
    redeclare package Medium = water,
    nPorts=1,
    p=200000,
    T=293.15)
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  inner Modelica.Fluid.System system
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Modelica.Fluid.Sources.FixedBoundary boundary2(
    redeclare package Medium = water,
    p=100000,
    T=293.15,
    nPorts= 3)
    annotation (Placement(transformation(extent={{82,-10},{62,10}})));
  Modelica.Fluid.Pipes.StaticPipe pipe2(
    redeclare package Medium = water,
    length=20,
    diameter=1) annotation (Placement(transformation(extent={{10,30},{30,50}})));
  Modelica.Fluid.Pipes.StaticPipe pipe3(
    redeclare package Medium = water,
    length=20,
    diameter=1.5)
    annotation (Placement(transformation(extent={{10,-50},{30,-30}})));
Modelica.Fluid.Pipes.StaticPipe pipe4(
    redeclare package Medium = water,
    length=20,
    diameter=1.5)
     annotation(
    Placement(visible = true, transformation(origin = {24, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(boundary1.ports[1], pipe1.port_a)
    annotation (Line(points={{-60,0},{-40,0}}, color={0,127,255}));
  connect(pipe1.port_b, pipe2.port_a) annotation (Line(points={{-20,0},{0,0},{0,
          40},{10,40}}, color={0,127,255}));
  connect(pipe1.port_b, pipe3.port_a) annotation (Line(points={{-20,0},{0,0},{0,
          -40},{10,-40}}, color={0,127,255}));
  connect(pipe2.port_b, boundary2.ports[1]) annotation (Line(points={{30,40},{40,
          40},{40,2},{62,2}}, color={0,127,255}));
  connect(pipe3.port_b, boundary2.ports[2]) annotation (Line(points={{30,-40},{40,
          -40},{40,-2},{62,-2}}, color={0,127,255}));
connect(pipe4.port_a, pipe1.port_b) annotation(
    Line(points = {{14, 0}, {-20, 0}}, color = {0, 127, 255}));
connect(pipe4.port_b, boundary2.ports[3]) annotation(
    Line(points = {{34, 0}, {62, 0}}, color = {0, 127, 255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    uses(Modelica(version="3.2.2")),
    experiment(StopTime=100, __Dymola_NumberOfIntervals=2000),
              Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end Example2;

