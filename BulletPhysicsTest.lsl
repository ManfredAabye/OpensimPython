
// Erklärung des Skripts

    // state_entry():
        // llSetPrimitiveParams([PRIM_PHYSICS, TRUE]): Aktiviert die physikalischen Eigenschaften des Objekts.
        // llApplyImpulse(<0, 0, -10>, FALSE): Wendet einen Impuls nach unten an, um die Schwerkraft zu testen.
        // llListen(0, "", NULL_KEY, ""): Aktiviert einen Listener, um auf Nachrichten zu reagieren (z.B. zum Zurücksetzen des Skripts).
        // llSetPrimitiveParams([...]): Setzt verschiedene Parameter wie Gravitation, Bounciness (Rückprall), Friction (Reibung), Drag (Luftwiderstand) und Omega (Rotation).
        // llSetTorque(<10, 0, 0>, FALSE): Wendet ein konstantes Drehmoment auf das Objekt an, um die Rotationsdynamik zu testen.
        // llSetPrimitiveParams([PRIM_FRICTION, 1.0]) und llSetPrimitiveParams([PRIM_BOUNCE, 1.0]): Setzt Reibung und Rückprall für das Objekt.

    // collision_start(integer num_detected):
        // Diese Funktion wird aufgerufen, wenn das Objekt mit einem anderen Objekt kollidiert. Es gibt die Anzahl der Kollisionen aus.

    // listen(integer channel, string name, key id, string message):
        // Diese Funktion hört auf Nachrichten und setzt das Skript zurück, wenn die Nachricht "reset" empfangen wird.

// Verwendung

    // Anwenden des Skripts: Füge das Skript einem Objekt in OpenSim hinzu.
    // Ausführen des Skripts: Wenn das Objekt physikalisch ist, werden die BulletPhysics-Funktionalitäten automatisch getestet.
    // Beobachtung: Beobachte das Verhalten des Objekts (Fall, Kollisionen, Rotation etc.) und konsultiere den Chat für Ausgaben.

// Anpassungen

    // Kollisionserkennung: Du könntest das Skript erweitern, um die Details der kollidierten Objekte (z.B. Position, Name) auszugeben.
    // Fortgeschrittene Tests: Integriere komplexere Szenarien, z.B. mehrere Objekte oder dynamische Parameteranpassungen während der Laufzeit.
    // Analyse: Füge mehr Ausgabeanweisungen hinzu, um die Ergebnisse der physikalischen Simulation detaillierter zu analysieren.

// Dieses Skript bietet eine grundlegende Grundlage, um die Hauptfunktionalitäten von BulletPhysics in OpenSim zu testen.

default
{
    state_entry()
    {
        llSay(0, "BulletPhysics Test Script gestartet.");

        // Aktiviert die Physik für das Objekt
        llSetPrimitiveParams([PRIM_PHYSICS, TRUE]);

        // Schwerkrafttest: Ein Impuls nach unten wird angewendet
        llApplyImpulse(<0, 0, -10>, FALSE);

        // Kollisionstest: Listener für Kollisionen aktivieren
        llListen(0, "", NULL_KEY, "");

        // Test der linearen und angularen Dämpfung
        llSetPrimitiveParams([PRIM_PHYSICS, TRUE, PRIM_FLEXIBLE, TRUE,
                              PRIM_GRAVITY, <0,0,-9.81>,
                              PRIM_BOUNCE, 0.5,
                              PRIM_FRICTION, 0.2,
                              PRIM_DRAG, 0.1,
                              PRIM_OMEGA, <0,0,1>, 0.2]);

        // Test von Drehmomenten: Ein konstantes Drehmoment wird angewendet
        llSetTorque(<10, 0, 0>, FALSE);
        
        // Test der Reibung: Die Reibungseigenschaft wird gesetzt
        llSetPrimitiveParams([PRIM_PHYSICS, TRUE, PRIM_FRICTION, 1.0]);

        // Test der Bounciness: Die Rückpralleigenschaft wird gesetzt
        llSetPrimitiveParams([PRIM_BOUNCE, 1.0]);
    }

    collision_start(integer num_detected)
    {
        llSay(0, "Kollision erkannt mit " + (string)num_detected + " Objekten.");
    }

    listen(integer channel, string name, key id, string message)
    {
        if (message == "reset")
        {
            llResetScript(); // Skript zurücksetzen
        }
    }
}
