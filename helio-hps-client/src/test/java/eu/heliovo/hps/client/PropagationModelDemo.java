package eu.heliovo.hps.client;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Vector;

import javax.xml.ws.BindingProvider;

import eu.heliovo.hps.server.AbstractApplicationDescription;
import eu.heliovo.hps.server.ApplicationParameter;
import eu.heliovo.hps.server.HPSService;
import eu.heliovo.hps.server.HPSServiceException_Exception;
import eu.heliovo.hps.server.HPSServiceService;
import eu.heliovo.shared.common.utilities.LogUtilities;
import eu.heliovo.shared.common.utilities.RandomUtilities;
import eu.heliovo.shared.hps.ApplicationExecutionStatus;

public class PropagationModelDemo {
	/*
	 * Various utilities
	 */
	LogUtilities logUtilities = new LogUtilities();
	RandomUtilities rndUtilities = new RandomUtilities();
	/*
	 * The Service Stubs
	 */
	HPSServiceService hpsSS = new HPSServiceService();
	// String serviceAddress =
	// "http://localhost:8080/helio-hps-server/hpsService";
	String serviceAddress = "http://cagnode58.cs.tcd.ie:8080/helio-hps-server/hpsService";

	public static void main(String[] args) {
		PropagationModelDemo pmDemo = new PropagationModelDemo();
		// pmDemo.runPropagationModel("CME", "2010-01-01T00:00", "0", "45",
		// "300", "0");
		// pmDemo.runPropagationModel("2010-01-01T00:00", "0", "45", "300");
		// pmDemo.runPropagationModel();
		pmDemo.runParallelApplications();
	}

	private void runParallelApplications() {
		String key = null;
		InputStreamReader reader = new InputStreamReader(System.in);
		BufferedReader in = new BufferedReader(reader);

		/*
		 * Stub for the hps server
		 */
		HPSService hpsService = hpsSS.getHPSServicePort();
		((BindingProvider) hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY, serviceAddress);

		/*
		 * Select the propagation model you want to use.
		 */
		System.out
				.print(" * How many paralled applications would you like to execute ? ");
		int parallelApps = 2;
		try {
			key = in.readLine();
			parallelApps = (Integer.valueOf(key).intValue());
		} catch (IOException e1) {
			e1.printStackTrace();
			parallelApps = 2;
		}
		System.out.println(" * You have selected to execute " + parallelApps
				+ " parallel applications");

		Vector<String> runningApplications = new Vector<String>();
		logUtilities.printShortLogEntry("Running " + parallelApps
				+ " parallel applications...");

		/*
		 * Retrieve the application list and selecting the appropriate
		 * propagation model.
		 */
		Vector<AbstractApplicationDescription> res = new Vector<AbstractApplicationDescription>();
		res.addAll(hpsService.getPresentApplications());

		// /*
		// * Selecting a random application
		// */
		// AbstractApplicationDescription app = res.get(selectRandomApp());
		// System.out.println(" * You have selected : " + app.getName());

		/*
		 * Selecting a vector of random applications
		 */
		Vector<AbstractApplicationDescription> apps = new Vector<AbstractApplicationDescription>();
		for (int n = 0; n < parallelApps; n++) 
		{
			int appNum = this.selectRandomApp();

			System.out.println(" * You have selected : "
					+ res.get(appNum).getName());

			AbstractApplicationDescription tmpApp = new AbstractApplicationDescription();
		
			tmpApp.setDescription(res.get(appNum).getDescription());
			tmpApp.setId(res.get(appNum).getId());
			tmpApp.setName(res.get(appNum).getName());
			tmpApp.getParameters().clear();
			/*
			 * Copying the params one by one
			 */
			for (int currParam = 0; currParam < res.get(appNum).getParameters()
					.size(); currParam++) 
			{
				ApplicationParameter	p	=	new ApplicationParameter();
				p.setDef(res.get(appNum).getParameters().get(currParam).getDef());
				p.setName(res.get(appNum).getParameters().get(currParam).getName());
				p.setType(res.get(appNum).getParameters().get(currParam).getType());
				p.setValue(res.get(appNum).getParameters().get(currParam).getValue());
				
				tmpApp.getParameters().add(p);
			}
			/*
			 * Select parameters for the propagation model
			 */
			for (int currParam = 0; currParam < tmpApp.getParameters()
					.size(); currParam++) {
				// System.out.println(" * Setting value for " +
				// app.getParameters().get(currParam).getName());
				/*
				 * If it is the staring date…
				 */
				if (tmpApp.getParameters().get(currParam).getName()
						.equals("CME's starting time")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SW's starting time")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SEP's starting time"))
					tmpApp.getParameters().get(currParam)
							.setValue(getRandomDate());
				/*
				 * If it is the starting point
				 */
				if (tmpApp.getParameters().get(currParam).getName()
						.equals("CME's starting point")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SW's starting point")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SEP's starting point"))
					tmpApp.getParameters().get(currParam)
							.setValue(getRandomPoint());
				/*
				 * If it is a hit point
				 */
				if (tmpApp.getParameters().get(currParam).getName()
						.equals("CME's hit object")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SW's hit object")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SEP's hit object"))
					tmpApp.getParameters().get(currParam)
							.setValue(getRandomObject());
				/*
				 * If it is a starting width
				 */
				if (tmpApp.getParameters().get(currParam).getName()
						.equals("CME's starting width"))
					tmpApp.getParameters().get(currParam)
							.setValue(getRandomWidth());
				/*
				 * If it is a starting speed
				 */
				if (tmpApp.getParameters().get(currParam).getName()
						.equals("CME's starting speed")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SW's starting speed")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SEP's starting speed"))
					tmpApp.getParameters().get(currParam)
							.setValue(getRandomSpeed());
				/*
				 * If it is an error speed
				 */
				if (tmpApp.getParameters().get(currParam).getName()
						.equals("CME's error speed")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SW's error speed")
						|| tmpApp.getParameters().get(currParam).getName()
								.equals("SEP's error speed"))
					tmpApp.getParameters().get(currParam)
							.setValue(getRandomErrorSpeed());
				if (tmpApp.getParameters().get(currParam).getName()
						.equals("Beta (Fraction of speed of light)"))
					tmpApp.getParameters().get(currParam)
							.setValue(getRandomBeta());
				
				System.out
						.println(" * Value of "
								+ tmpApp.getParameters().get(currParam)
										.getName()
								+ " is "
								+ tmpApp.getParameters().get(currParam)
										.getValue());

			}
			apps.add(tmpApp);
		}

		/*
		 * Submitting application to the fast grid...
		 */
		for (int n = 0; n < parallelApps; n++) {
			try {
				runningApplications.add(hpsService.executeApplication(
						apps.get(n), true, 1));
			} catch (HPSServiceException_Exception e) {
				e.printStackTrace();
			}
		}
		/*
		 * Waiting for the application to complete ...
		 */
		boolean allDone = false;
		while (!allDone) {
			allDone = true;
			for (int n = 0; n < parallelApps; n++) {
				String currId = runningApplications.get(n);
				String currStatus = hpsService.getStatusOfExecution(currId);
				logUtilities.printShortLogEntry(apps.get(n).getName() + " --> "
						+ currId + " --> " + currStatus);
				if (!currStatus.equals(ApplicationExecutionStatus.Completed))
					allDone = false;
			}
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}

		/*
		 * Getting the output of the applications ...
		 */
		for (int n = 0; n < parallelApps; n++) {
			String currId = runningApplications.get(n);
			String currOutput = "undefined";
			try {
				currOutput = hpsService.getOutputOfExecution(currId);
			} catch (HPSServiceException_Exception e) {
				e.printStackTrace();
			}
			logUtilities.printShortLogEntry(apps.get(n).getName() + " --> "
					+ currId + " --> " + currOutput);
		}
	}

	private String getRandomBeta() {
		return "0.9";
	}

	private void runSingleApplications() {
		/*
		 * Stub for the hps server
		 */
		HPSService hpsService = hpsSS.getHPSServicePort();
		((BindingProvider) hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY, serviceAddress);

		int parallelApps = 20;
		Vector<AbstractApplicationDescription> submittedApplications = new Vector<AbstractApplicationDescription>();
		logUtilities.printShortLogEntry("Running " + parallelApps
				+ " parallel applications...");

		/*
		 * Retrieve the application list and selecting the appropriate
		 * propagation model.
		 */
		Vector<AbstractApplicationDescription> res = new Vector<AbstractApplicationDescription>();
		res.addAll(hpsService.getPresentApplications());

		// for(int n = 0; n < res.size(); n++)
		// {
		// System.out.println("[" +
		// n
		// + "] ==> : " +
		// res.get(n).getName());
		// }
		/*
		 * Selecting a random application
		 */
		AbstractApplicationDescription app = res.get(selectRandomApp());
		System.out.println(" * You have selected : " + app.getName());

		/*
		 * Select parameters for the propagation model
		 */
		for (int currParam = 0; currParam < app.getParameters().size(); currParam++) {
			// System.out.println(" * Setting value for " +
			// app.getParameters().get(currParam).getName());
			/*
			 * If it is the staring date…
			 */
			if (app.getParameters().get(currParam).getName()
					.equals("CME's starting time")
					|| app.getParameters().get(currParam).getName()
							.equals("SW's starting time")
					|| app.getParameters().get(currParam).getName()
							.equals("SEP's starting time"))
				app.getParameters().get(currParam).setValue(getRandomDate());
			/*
			 * If it is the starting point
			 */
			if (app.getParameters().get(currParam).getName()
					.equals("CME's starting point")
					|| app.getParameters().get(currParam).getName()
							.equals("SW's starting point")
					|| app.getParameters().get(currParam).getName()
							.equals("SEP's starting point"))
				app.getParameters().get(currParam).setValue(getRandomPoint());
			/*
			 * If it is a hit point
			 */
			if (app.getParameters().get(currParam).getName()
					.equals("CME's hit object")
					|| app.getParameters().get(currParam).getName()
							.equals("SW's hit object")
					|| app.getParameters().get(currParam).getName()
							.equals("SEP's hit object"))
				app.getParameters().get(currParam).setValue(getRandomObject());
			/*
			 * If it is a starting width
			 */
			if (app.getParameters().get(currParam).getName()
					.equals("CME's starting width"))
				app.getParameters().get(currParam).setValue(getRandomWidth());
			/*
			 * If it is a starting speed
			 */
			if (app.getParameters().get(currParam).getName()
					.equals("CME's starting speed")
					|| app.getParameters().get(currParam).getName()
							.equals("SW's starting speed")
					|| app.getParameters().get(currParam).getName()
							.equals("SEP's starting speed"))
				app.getParameters().get(currParam).setValue(getRandomSpeed());
			/*
			 * If it is an error speed
			 */
			if (app.getParameters().get(currParam).getName()
					.equals("CME's error speed")
					|| app.getParameters().get(currParam).getName()
							.equals("SW's error speed")
					|| app.getParameters().get(currParam).getName()
							.equals("SEP's error speed"))
				app.getParameters().get(currParam)
						.setValue(getRandomErrorSpeed());
			System.out.println(" * Value of "
					+ app.getParameters().get(currParam).getName() + " is "
					+ app.getParameters().get(currParam).getValue());
		}

		/*
		 * Submitting application to the fast grid...
		 */
		String exeId = null;
		try {
			exeId = hpsService.executeApplication(app, true, 1);
		} catch (HPSServiceException_Exception e) {
			e.printStackTrace();
		}
		System.out.println(" * " + app.getName() + " submitted as " + exeId);
		/*
		 * Waiting for the application to complete ...
		 */
		String exeStatus = "undefined";
		while (!exeStatus.equals(ApplicationExecutionStatus.Completed)) {
			exeStatus = hpsService.getStatusOfExecution(exeId);
			logUtilities.printShortLogEntry(exeId + " --> " + exeStatus);
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		/*
		 * Getting the output of the applications ...
		 */
		String exeOutput = null;
		try {
			exeOutput = hpsService.getOutputOfExecution(exeId);
		} catch (HPSServiceException_Exception e) {
			e.printStackTrace();
		}
		logUtilities
				.printShortLogEntry("Results of the propagation model are available in "
						+ exeOutput);
	}

	private String getRandomErrorSpeed() {
		return String.valueOf(rndUtilities.getRandomBetween(10, 100));
	}

	private String getRandomSpeed() {
		return String.valueOf(rndUtilities.getRandomBetween(500, 800));
	}

	private String getRandomWidth() {
		return String.valueOf(rndUtilities.getRandomBetween(0, 90));
	}

	private String getRandomObject() {
		int rndNum = rndUtilities.getRandomBetween(0, 15);
		if (rndNum < 3)
			return "Earth";
		else if (rndNum < 6)
			return "Jupiter";
		else if (rndNum < 9)
			return "StereoA";
		else if (rndNum < 12)
			return "Messenger";
		else if (rndNum < 15)
			return "Voyager1";
		else
			return "Pluto";
	}

	private String getRandomPoint() {
		return String.valueOf(rndUtilities.getRandomBetween(0, 180));
	}

	private String getRandomDate() {
		return "2012-01-01T00:00";
	}

	private int selectRandomApp() {
		 int res = rndUtilities.getRandomBetween(0, 5);
		 logUtilities.printShortLogEntry("Selecting application n: " + res);
		 return res;
		// return 5;
	}

	private void runPropagationModel() {
		HPSService hpsService = hpsSS.getHPSServicePort();
		((BindingProvider) hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY, serviceAddress);

		Boolean fastExecution = true;
		int numJobs = 1;
		AbstractApplicationDescription app = null;
		String key = null;
		String exeId = null;
		String exeStatus = null;
		String exeOutput = null;
		InputStreamReader reader = new InputStreamReader(System.in);
		BufferedReader in = new BufferedReader(reader);

		try {
			/*
			 * Retrieve the application list and selecting the appropriate
			 * propagation model.
			 */
			Vector<AbstractApplicationDescription> res = new Vector<AbstractApplicationDescription>();
			res.addAll(hpsService.getPresentApplications());

			for (int n = 0; n < res.size(); n++) {
				System.out.println("[" + n + "] ==> : " + res.get(n).getName());
			}
			/*
			 * Select the propagation model you want to use.
			 */
			System.out.print(" * Enter corresponding value : ");
			key = in.readLine();
			app = res.get(Integer.valueOf(key).intValue());
			System.out.println(" * You have selected : " + app.getName());
			/*
			 * Select parameters for the propagation model
			 */
			for (int currParam = 0; currParam < app.getParameters().size(); currParam++) {
				System.out
						.print(" * Enter value for "
								+ app.getParameters().get(currParam).getName()
								+ " ["
								+ app.getParameters().get(currParam).getType()
								+ "] : ");
				key = in.readLine();
				app.getParameters().get(currParam).setValue(key);
			}
			/*
			 * Submitting one instance of the application to the fast
			 * computation resource
			 */
			exeId = hpsService.executeApplication(app, fastExecution, numJobs);
			logUtilities.printShortLogEntry(app.getName()
					+ " is being executed with execution ID " + exeId);
			/*
			 * Wait until the application is completed
			 */
			exeStatus = hpsService.getStatusOfExecution(exeId);
			logUtilities.printShortLogEntry(exeId + " --> " + exeStatus);
			while (!exeStatus.equals(ApplicationExecutionStatus.Completed)) {
				exeStatus = hpsService.getStatusOfExecution(exeId);
				logUtilities.printShortLogEntry(exeId + " --> " + exeStatus);
				Thread.sleep(1000);
			}
			exeOutput = "http://cagnode58.cs.tcd.ie/output_dir/" + exeId;
			logUtilities
					.printShortLogEntry("Results of the propagation model are available in "
							+ exeOutput);
		} catch (Exception e) {
			e.printStackTrace();
		}
		logUtilities
				.printShortLogEntry("--------------------------------------------------");
		logUtilities.printShortLogEntry("... done");
	}

	private void runPropagationModel(String pmType, String time, String angle,
			String width, String speed, String speedError) {
		HPSService hpsService = hpsSS.getHPSServicePort();
		((BindingProvider) hpsService).getRequestContext().put(
				BindingProvider.ENDPOINT_ADDRESS_PROPERTY, serviceAddress);

		Boolean fastExecution = true;
		int numJobs = 1;
		AbstractApplicationDescription app = null;
		String key = null;
		String exeId = null;
		String exeStatus = null;
		String exeOutput = null;
		InputStreamReader reader = new InputStreamReader(System.in);
		BufferedReader in = new BufferedReader(reader);

		try {
			/*
			 * Retrieve the application list and select the propagation model.
			 */
			Vector<AbstractApplicationDescription> res = new Vector<AbstractApplicationDescription>();
			res.addAll(hpsService.getPresentApplications());
			app = res.get(0);
			/*
			 * Define parameters
			 */
			/*
			 * Date
			 */
			app.getParameters().get(0).setValue(time);
			/*
			 * Longitude
			 */
			app.getParameters().get(1).setValue(angle);
			/*
			 * Width
			 */
			app.getParameters().get(2).setValue(width);
			/*
			 * Speed
			 */
			app.getParameters().get(3).setValue(speed);

			exeId = hpsService.executeApplication(app, fastExecution, numJobs);
			logUtilities.printShortLogEntry(app.getName()
					+ " is being executed with execution ID " + exeId);
			/*
			 * Wait until the application is completed
			 */

			exeStatus = hpsService.getStatusOfExecution(exeId);
			logUtilities.printShortLogEntry(exeId + " --> " + exeStatus);
			while (!exeStatus.equals(ApplicationExecutionStatus.Completed)) {
				exeStatus = hpsService.getStatusOfExecution(exeId);
				logUtilities.printShortLogEntry(exeId + " --> " + exeStatus);
				Thread.sleep(1000);
			}
			// /*
			// * If the application is completed, retrieve the output and
			// * remove from the list of running applications
			// */
			// if (exeStatus.equals(ApplicationExecutionStatus.Completed))
			// {
			// logUtilities.printShortLogEntry(exeId + " --> " +
			// hpsService.getOutputOfExecution(exeId));
			// }
		} catch (Exception e) {
			e.printStackTrace();
		}

		logUtilities
				.printShortLogEntry("--------------------------------------------------");
		logUtilities.printShortLogEntry("... done");
	}
}
