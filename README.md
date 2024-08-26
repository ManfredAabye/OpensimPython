# PythonNet .NET 8.0
https://github.com/pythonnet/pythonnet

Erläuterungen zu den Änderungen:

    * PythonNet Initialisierung:
        PythonEngine.Initialize(); wird verwendet, um die Python-Umgebung zu initialisieren. PythonNet benötigt eine explizite Initialisierung und Freigabe.
        using (Py.GIL()) sorgt dafür, dass der aktuelle Thread den Global Interpreter Lock (GIL) von Python besitzt, was bei der Ausführung von Python-Code zwingend notwendig ist.

    * Pfadkonfiguration:
        Die Pfade werden direkt über das sys-Modul von Python hinzugefügt.

    * Python-Skripte ausführen:
        Die Methode Py.Import lädt Python-Module. Fehler in Python werden durch PythonException abgefangen, und die Ausführung wird protokolliert.

    * Shutdown:
        Die Python-Umgebung wird durch PythonEngine.Shutdown(); korrekt heruntergefahren, um Speicherlecks zu vermeiden.

* Installation von PythonNet
Um PythonNet in das .NET 8.0 Projekt einzubinden, kannst du das pythonnet NuGet-Paket installieren:

* bash:
dotnet add package Pythonnet

* Fazit
Der angepasste Code verwendet nun PythonNet anstelle von IronPython, ist für Python 3.x ausgelegt und kompatibel mit .NET 8.0.
