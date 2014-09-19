using System;
using System.ServiceProcess;
using System.Diagnostics;
using System.Timers;

/// <summary>
/// A service to run cjdns on Windows. Handles all the service things 
/// needed to tie into the Windows service system.
/// </summary>
public class CjdnsService: ServiceBase { 
	
	private Process cjdns;
	private Timer cjdnsPoller;
	
	
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
		
		// Make sure no other instances of cjdns are running 
		// (like if we killed this process without killing our child cjdns)
		foreach (Process otherCjdns in Process.GetProcessesByName("cjdroute")) {
		    otherCjdns.Kill();
		}
		
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
        
        cjdnsPoller = new Timer(10000);
        cjdnsPoller.Elapsed += new ElapsedEventHandler(cjdnsPoller_Elapsed);
        cjdnsPoller.Start();
        
	}

	void cjdnsPoller_Elapsed(object sender, ElapsedEventArgs e)
	{
		cjdns.Refresh();
		if(cjdns.HasExited) {
			// Die sadly
			Environment.Exit(1);
		}
	}
	
	protected override void OnStop() {
		// Stop the timer
		cjdnsPoller.Stop();
		
		// Collect info from the cjdns process
		cjdns.Refresh();
		if(!cjdns.HasExited) {
			// Kill it if it isn't dead
			cjdns.Kill();
		}
	}
	
	public static void Main() {
		// Make and run the service
		System.ServiceProcess.ServiceBase.Run(new CjdnsService());
	}
}