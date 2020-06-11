package Marslanding
  class Body "generic body"
    Real mass(unit="Kg", min=0);
    String name;
  end Body;

  class CeiestiaiBody
    extends Body;
    constant Real g = 6.672e-11"constante gravitationnelle";
    parameter Real radius"le rayon du Corps céleste";
  end CeiestiaiBody;

  class Rocket"class à utiliser dans Moonlanding et Marslanding pour éviter la répétition "
    extends Body;
  parameter Real massLossRate=0.000277;
  Real altitude(start= 59404,unit="m");
  //valeurs initiaux
  Real velocity(start= -2003,unit="m/s");
  Real acceleration(unit="m/s^2");
  Real thrust(unit="N");
  Real gravity(unit="m/s^2");
  equation
  (thrust - mass * gravity)/mass =  acceleration;
//calcul de l'acceleration
    der(mass) = -massLossRate * abs(thrust);
//calcul de la variation de la masse de la fusee
    der(altitude) = velocity;
//calcul de la variation de l'altitude de la fusee
    der(velocity) = acceleration;
//calcul de la variation de la vitesse de la fusee
  end Rocket;

  class Moonlanding
  parameter Real forcel(unit = "N") = 36350;
    //La force de poussée de la fusée avant un temps de 43,2 secondes
    parameter Real force2(unit = "N") = 1308;
    //La force de poussée de la fusée aprés 43,2 secondes et avant 210
  protected
    //Les parametres ci-dessus ne seront pas visible dans les variables la sectione tracé
    parameter Real thrustEndTime(unit = "s") = 210;
    parameter Real thrustDecreaseTime(unit = "s") = 43.2;
  public
    //Les parametres ci-dessus seront visible dans les variables la sectione tracé
    Rocket apollo(name = "apollol3", mass(start = 1038.358));
    CeiestiaiBody moon(mass = 7.382e22, radius = 1.738e6, name = "moon");
    //Proprietes de la lune
  equation
    apollo.thrust = if time < thrustDecreaseTime then forcel else if time < thrustEndTime then force2 else 0;
// calcul de la variation de la force de poussée
    apollo.gravity = moon.g * moon.mass / (apollo.altitude + moon.radius) ^ 2;
// calcul de la variation de la force de gravity
    when apollo.altitude < 0 then
      terminate("La fusee touche le sol de la lune");
    end when;
    when apollo.velocity < 0 then
      terminate("La fusee touche le sol de la lune");
    end when;
  end Moonlanding;

  class Marslanding
  extends Moonlanding;
  CeiestiaiBody mars(mass=6.391e23,radius=3.3895e6,name="mars");
    Rocket apolloM(name="apollol3", mass(start=1038.358));
  equation 
    apolloM.thrust = if (time<thrustDecreaseTime) then ((forcel-apollo.mass*apollo.gravity)*(apolloM.mass/apollo.mass))+(apolloM.mass*apolloM.gravity)
   else 
       if (time<thrustEndTime) then ((force2-apollo.mass*apollo.gravity)*(apolloM.mass/apollo.mass))+(apolloM.mass*apolloM.gravity)
   else 
       0;
  apolloM.gravity = mars.g*mars.mass /(apolloM.altitude+mars.radius)^2;
  when apolloM.altitude < 0 then
// termination condition
      terminate("La fusee touche le sol du Mars");
    end when;
  when apolloM.velocity < 0 then
// termination condition
      terminate("La fusee touche le sol du Mars");
    end when;
  end Marslanding;
end Marslanding;
