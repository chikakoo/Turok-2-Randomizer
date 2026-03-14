#include "defs/randoConstants.txt"

// Off-world AP item - using life force so it will be collected no matter what
// For now, you'll get a life force, but whatever
APItem kActor_Item_APItem
{
    className                   "kexLifeForcePickup"
    placeable                   TRUE
    flags.noDamage              TRUE
    pickup.pickupSound          "sounds/shaders/Health Pickup Sound.ksnd"
    
    initialScale              "0.5 0.5 0.5"
    Begin_Component "kexWorldComponent"
        radius                81.92
        height                81.92
        bNonSolid             TRUE
    End_Component
    Begin_Component "kexStaticMeshComponent"
        mesh                  "models/Pickup_Life_Force_1_02.staticmesh"
    End_Component
    Begin_Component "kexScriptComponent"
        scriptClass           "RandoPickupObject"
        triggerRadius         81.92
    End_Component
}