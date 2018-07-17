with text_io; use text_io;
with Multi_Printer; use Multi_Printer;

procedure Main is

    type String_P is access all String;
    task type Vehicle( LicensePlateNumber : String_P := null ); -- Jármű taszk (Vehicle)

    type Vehicle_P is access Vehicle; 

    type Colors is (Piros, PirosSarga, Zold, Sarga);

    task type Signal;
    type signal_sender_type is access Signal;

    protected Lamp is
        procedure Switch;
        function GetColor return Colors;
    private
        signal_sender : signal_sender_type;
        color : Colors := Piros;
    end Lamp;

    task Controller is
        entry Stop;
    end Controller;

    task body Controller is 
        working: Boolean := True;        
    begin
        while working loop
            select 
                accept Stop do
                    working := False;
                end Stop;
            else
                case Lamp.GetColor is
                    when Piros => delay(3.0); Lamp.Switch;
                    when PirosSarga => delay(1.0); Lamp.Switch;
                    when Sarga => delay(1.0); Lamp.Switch;
                    when Zold => delay(3.0); Lamp.Switch;
                end case;
            end select;
        end loop;
    end Controller; 

    protected body Lamp is
        procedure Switch is
        begin
            case Lamp.color is
                when Piros => color := PirosSarga;
                when PirosSarga => color := Zold;
                when Sarga => color := Piros;
                when Zold => color := Sarga;
            end case;
            signal_sender := new Signal;
            Monitor.Print("LAMP" & Colors'Image(color));
        end Switch;

        function GetColor return Colors is
        begin
            return color;
        end GetColor;
    end Lamp;

    protected Crossroads is
        entry Cross(t: Duration; plateNum : String_P);
        procedure Wake_Up;
    end Crossroads;

    protected body Crossroads is
        entry Cross(t: Duration; plateNum : String_P) when Lamp.GetColor = Zold is
        begin
			Monitor.Print(plateNum.all & " a kereszteződésben" );
            delay(t);
			Monitor.Print(plateNum.all & " a kereszteződés végén" );
        end Cross;

        procedure Wake_Up is
        begin
			null;
        end Wake_Up;
    end Crossroads;

    task body Signal is
    begin
        Crossroads.Wake_Up;
    end Signal;

    task body Vehicle is
        rt: Duration;
        procedure Arrive is 
        begin
            if LicensePlateNumber /= null then
                Monitor.Print ( LicensePlateNumber.all & " rendszámú autó beérkezik a kereszteződésbe" );
            end if;
        end Arrive;
    begin
        Arrive;
        Randomize.Timing(rt,0.1,0.5);
        select
            Crossroads.Cross(rt, LicensePlateNumber);
        else
            Crossroads.Cross(rt + 2.0, LicensePlateNumber);
        end select;  
        Monitor.Print ( LicensePlateNumber.all & " rendszámú autó áthajtott a kereszteződésen" );    
    end Vehicle;

    Vehicles : array(1..2) of Vehicle;
    ThisVehicle : Vehicle_P;

begin
    Randomize.Init;
    ThisVehicle := new Vehicle( new String'("KBN-642") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("KPJ-659") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("MNJ-659") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("HJW-123") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("LCJ-612") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("ASD-123") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("HMN-654") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("LKM-543") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("KLT-145") );
    delay 0.5;
    ThisVehicle := new Vehicle( new String'("GTU-123") );
    delay 20.0;
    --Controller.Stop;
end Main;