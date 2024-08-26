using System;
using System.Collections.Generic;
using System.Reflection;
using System.IO;

using log4net;
using Nini.Config;
using OpenMetaverse;

using OpenSim.Framework;
using OpenSim.Region.Framework.Interfaces;
using OpenSim.Region.Framework.Scenes;

using Python.Runtime;

/* PythonNet .NET 8.0
https://github.com/pythonnet/pythonnet

! Erläuterungen zu den Änderungen:

    ? PythonNet Initialisierung:
        PythonEngine.Initialize(); wird verwendet, um die Python-Umgebung zu initialisieren. PythonNet benötigt eine explizite Initialisierung und Freigabe.
        using (Py.GIL()) sorgt dafür, dass der aktuelle Thread den Global Interpreter Lock (GIL) von Python besitzt, was bei der Ausführung von Python-Code zwingend notwendig ist.

    ? Pfadkonfiguration:
        Die Pfade werden direkt über das sys-Modul von Python hinzugefügt.

    ? Python-Skripte ausführen:
        Die Methode Py.Import lädt Python-Module. Fehler in Python werden durch PythonException abgefangen, und die Ausführung wird protokolliert.

    ? Shutdown:
        Die Python-Umgebung wird durch PythonEngine.Shutdown(); korrekt heruntergefahren, um Speicherlecks zu vermeiden.

! Installation von PythonNet
Um PythonNet in das .NET 8.0 Projekt einzubinden, kannst du das pythonnet NuGet-Paket installieren:

? bash:
dotnet add package Pythonnet

! Fazit
Der angepasste Code verwendet nun PythonNet anstelle von IronPython, ist für Python 3.x ausgelegt und kompatibel mit .NET 8.0.
*/

namespace PythonModuleLoader
{
    public class PythonRegionModuleHook : IRegionModuleBase
    {
        private static readonly ILog m_log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);

        Scene m_scene;
        IConfigSource m_config;

        #region IRegionModule interface

        public void Initialise(Scene scene, IConfigSource config)
        {
            m_log.Info("[PythonModuleLoader] Initializing...");

            m_scene = scene;
            m_config = config;

            // Set up PythonNet environment
            // Ensure the Python runtime is initialized correctly
            PythonEngine.Initialize();

            using (Py.GIL()) // Acquire the Global Interpreter Lock
            {
                // Add current directory and custom search paths for Python modules
                dynamic sys = Py.Import("sys");
                sys.path.append(AppDomain.CurrentDomain.BaseDirectory);
                sys.path.append(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ScriptEngines"));

                m_log.Info("Added " + AppDomain.CurrentDomain.BaseDirectory + " to python module search path");
            }
        }

        public void PostInitialise()
        {
            using (Py.GIL()) // Acquire the Global Interpreter Lock
            {
                try
                {
                    dynamic pymodloader = Py.Import("pymodloader");
                    pymodloader.sceneinit(m_scene, m_config);
                }
                catch (PythonException ex)
                {
                    m_log.Error("[PythonModuleLoader] Python error:", ex);
                }
            }
        }

        public void Close()
        {
            // Clean up Python environment if necessary
            PythonEngine.Shutdown();
        }

        public void Initialise(IConfigSource source)
        {
            throw new NotImplementedException();
        }

        public void AddRegion(Scene scene)
        {
            throw new NotImplementedException();
        }

        public void RemoveRegion(Scene scene)
        {
            throw new NotImplementedException();
        }

        public void RegionLoaded(Scene scene)
        {
            throw new NotImplementedException();
        }

        public string Name
        {
            get { return "Python module loader"; }
        }

        public bool IsSharedModule
        {
            get { return false; }
        }

        public Type ReplaceableInterface => throw new NotImplementedException();

        #endregion
    }
}
