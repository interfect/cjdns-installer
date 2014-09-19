using System;
using System.ServiceProcess;
using System.Diagnostics;

/// <summary>
/// A service to run cjdns on Windows. Handles all the service things 
/// needed to tie into the Windows service system.
/// </summary>
public class CjdnsService: ServiceBase { 
	
	private Process cjdns;
	private EventHandler exitedHandler;
	
	public CjdnsService() {
		// Configure the service info
		this.ServiceName = "Cjdns Watcher";
		this.CanStop = true;
		this.CanPauseAndContinue = false;
		this.AutoLog = true;
	}
	
	protected override void OnStart(string [] args) {
		// Pop over to the directory where we actually live. 
		// See <http://stackoverflow.com/a/885081/402891>
		System.IO.Directory.SetCurrentDirectory(System.AppDomain.CurrentDomain.BaseDirectory);
		
		// Make a new process to babysit
		cjdns = new Process();
		
		// Point it at the executable
		cjdns.StartInfo.FileName = "cjdroute.exe";
		// Don't use the Windows shell
		cjdns.StartInfo.UseShellExecute = false;
		// Make sure it doesn't background itself, so we can kill it.
		cjdns.StartInfo.Arguments = "--nobg";
		// We're going to have it read its config file
        cjdns.StartInfo.RedirectStandardInput = true;

    	// Start up cjdns
        cjdns.Start();

        // Dump in the config file
        cjdns.StandardInput.WriteLine(System.IO.File.ReadAllText("cjdroute.conf"));
        
        // Close up the stream and let the process run.
        cjdns.StandardInput.Close();
        
        // When cjdns stops, throw an exception
        exitedHandler = new EventHandler(cjdns_Exited);
        cjdns.Exited  += exitedHandler;
	}

	void cjdns_Exited(object sender, EventArgs e)
	{
		throw new Exception("cjdns stopped");
	}
	
	protected override void OnStop() {
		// Collect info from the cjdns process
		cjdns.Refresh();
		if(!cjdns.HasExited) {
			// We're going to kill cjdns, so don't die when that happens.
			cjdns.Exited -= exitedHandler;
			
			// Kill it if it isn't dead
			cjdns.Kill();
		}
	}
	
	public static void Main() {
		// Make and run the service
		System.ServiceProcess.ServiceBase.Run(new CjdnsService());
	}
}